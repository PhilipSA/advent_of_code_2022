import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day17() {
  final fileLines = getInputFileLines(17);

  final part1 = day17Read(fileLines, false);
  final part2 = 2; //day17Read(fileLines, true);
  print('Day 17 part 1: $part1 part 2: $part2');
}

int day17Read(List<String> fileLines, bool part2) {
  final tetrisBoard = TetrisBoard.createFromFileLine(fileLines);
  final height = tetrisBoard.runTetrisGame();
  tetrisBoard.drawTetrisBoard();
  return height;
}

class TetrisBoard {
  final List<TetrisBlock> availableTetrisBlocks = [];
  final List<PushDirection> pushQueue = [];
  TetrisBlock? currentHighestTetrisBlock;
  final Set<Coordinates> occupiedSpaces =
      Set.from(List.generate(8, (i) => Coordinates(i, 4)));

  final rightWallX = 7;
  final leftWallX = 0;

  TetrisBoard();

  factory TetrisBoard.createFromFileLine(List<String> fileLines) {
    final tetrisBoard = TetrisBoard();

    // #### shape
    tetrisBoard.availableTetrisBlocks.add(
      TetrisBlock([
        Coordinates(0, 0),
        Coordinates(1, 0),
        Coordinates(2, 0),
        Coordinates(3, 0)
      ]),
    );
    /*.#.
      ###
      .#. shape*/
    tetrisBoard.availableTetrisBlocks.add(
      TetrisBlock([
        Coordinates(1, 0),
        Coordinates(0, 1),
        Coordinates(1, 1),
        Coordinates(2, 1),
        Coordinates(1, 2),
      ]),
    );
    /*..#
      ..#
      ### shape*/
    tetrisBoard.availableTetrisBlocks.add(
      TetrisBlock([
        Coordinates(2, 0),
        Coordinates(2, 1),
        Coordinates(0, 2),
        Coordinates(1, 2),
        Coordinates(2, 2),
      ]),
    );
    /*#
      #
      #
      # shape*/
    tetrisBoard.availableTetrisBlocks.add(
      TetrisBlock([
        Coordinates(0, 0),
        Coordinates(0, 1),
        Coordinates(0, 2),
        Coordinates(0, 3),
      ]),
    );
    /*##
      ## shape*/
    tetrisBoard.availableTetrisBlocks.add(
      TetrisBlock([
        Coordinates(0, 0),
        Coordinates(1, 0),
        Coordinates(0, 1),
        Coordinates(1, 1),
      ]),
    );

    tetrisBoard.pushQueue.addAll(
      fileLines.first
          .split('')
          .map((e) => e == '<' ? PushDirection.Left : PushDirection.Right),
    );

    return tetrisBoard;
  }

  int runTetrisGame() {
    var currentBlockIteration = 0;
    var currentPushQueueIteration = 0;

    while (currentBlockIteration != 5) {
      //Blocks start 3 steps away from left wall and 2 away from right wall. 3 steps lower than lowest Y-value
      final currentTetrisBlock = availableTetrisBlocks[
          currentBlockIteration % availableTetrisBlocks.length]
        ..currentPositionOffset = Coordinates(
          3,
          currentHighestTetrisBlock != null
              ? currentHighestTetrisBlock!.lowestYValue - 4
              : 0,
        );

      while (true) {
        final currentPushDirection =
            pushQueue[currentPushQueueIteration % pushQueue.length];
        ++currentPushQueueIteration;

        final willCollideWithRightWall =
            currentPushDirection == PushDirection.Right &&
                currentTetrisBlock.currentPosition.any(
                  (element) => element.x + 1 == rightWallX,
                );
        final willCollideWithLeftWall =
            currentPushDirection == PushDirection.Right &&
                currentTetrisBlock.currentPosition.any(
                  (element) => element.x - 1 == leftWallX,
                );

        //Check for collision with wall
        if (!willCollideWithRightWall && !willCollideWithLeftWall) {
          currentTetrisBlock.pushInDirection(currentPushDirection);
        }

        //There is something below blocking us
        if (currentTetrisBlock.currentPosition.any(
          (element) =>
              occupiedSpaces.contains(Coordinates(element.x, element.y + 1)),
        )) {
          break;
        }

        currentTetrisBlock.pushInDirection(PushDirection.Down);
      }

      if (currentHighestTetrisBlock == null ||
          currentTetrisBlock.lowestYValue >
              currentHighestTetrisBlock!.lowestYValue) {
        currentHighestTetrisBlock = currentTetrisBlock;
      }
      occupiedSpaces.addAll(currentTetrisBlock.currentPosition);
      ++currentBlockIteration;
    }

    return currentHighestTetrisBlock!.lowestYValue;
  }

  void drawTetrisBoard() {
    final linesToDraw = <String>[];

    for (var y = -50; y < 4; ++y) {
      var yLine = "|";
      for (var x = 0; x < 7; ++x) {
        final objectAtCoords = occupiedSpaces.contains(Coordinates(x, y));
        yLine += objectAtCoords ? '#' : '.';
      }
      linesToDraw.add(yLine + '|');
    }
    print(linesToDraw.join('\n'));
  }
}

class Coordinates {
  int x;
  int y;

  Coordinates(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (other is Coordinates) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  @override
  int get hashCode {
    return x.hashCode ^ y.hashCode;
  }
}

class TetrisBlock {
  final List<Coordinates> baseShape;
  Coordinates currentPositionOffset = Coordinates(0, 0);

  List<Coordinates> get currentPosition => baseShape
      .map(
        (e) => Coordinates(
          e.x + currentPositionOffset.x,
          e.y + currentPositionOffset.y,
        ),
      )
      .toList();

  int get lowestYValue =>
      currentPosition.sorted((a, b) => a.y.compareTo(b.y)).first.y;

  int get highestYValue =>
      currentPosition.sorted((a, b) => a.y.compareTo(b.y)).last.y;

  void pushInDirection(PushDirection pushDirection) {
    switch (pushDirection) {
      case PushDirection.Down:
        currentPositionOffset =
            Coordinates(currentPositionOffset.x, currentPositionOffset.y + 1);
        break;
      case PushDirection.Left:
        currentPositionOffset =
            Coordinates(currentPositionOffset.x - 1, currentPositionOffset.y);
        break;
      case PushDirection.Right:
        currentPositionOffset =
            Coordinates(currentPositionOffset.x + 1, currentPositionOffset.y);
        break;
    }
  }

  TetrisBlock(this.baseShape);
}

enum PushDirection { Left, Right, Down }
