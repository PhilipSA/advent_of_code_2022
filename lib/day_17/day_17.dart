import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day17() {
  final fileLines = getInputFileLines(17);

  final part1 = day17Read(fileLines, false);
  final part2 = day17Read(fileLines, true);
  print('Day 17 part 1: $part1 part 2: $part2');
}

int day17Read(List<String> fileLines, bool part2) {
  final tetrisBoard = TetrisBoard.createFromFileLine(fileLines);
  final height = tetrisBoard.runTetrisGame(part2 ? 10000 : 2023);
  if (part2) {
    return tetrisBoard.calculateHeightAt();
  }
  return height;
}

class TetrisBoard {
  final List<TetrisBlock> availableTetrisBlocks = [];
  final List<PushDirection> pushQueue = [];
  final List<TetrisBlock> heightHistory = [];
  final List<Coordinates> occupiedSpaces = List.generate(
    8,
    (i) => Coordinates(i, -4),
  );
  final List<State> states = [];

  final rightWallX = 7;
  final leftWallX = -1;

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
        Coordinates(0, 0),
        Coordinates(1, 0),
        Coordinates(2, 0),
        Coordinates(2, 1),
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

  int runTetrisGame(int iterations) {
    var currentBlockIteration = 0;
    var currentPushQueueIteration = 0;

    while (currentBlockIteration != iterations) {
      //Blocks start 3 steps away from left wall and 2 away from right wall. 3 steps lower than lowest Y-value
      final currentTetrisBlock = availableTetrisBlocks[
          currentBlockIteration % availableTetrisBlocks.length];

      final currentHighestTetrisBlock = heightHistory.lastOrNull;

      currentTetrisBlock.currentPositionOffset = Coordinates(
        2,
        heightHistory.isNotEmpty
            ? currentHighestTetrisBlock!.highestYValue + 4
            : 0,
      );

      final currentState = State(
        currentPushQueueIteration % pushQueue.length,
        currentBlockIteration % availableTetrisBlocks.length,
        occupiedSpaces
            .where(
              (element) =>
                  element.y == currentHighestTetrisBlock?.highestYValue,
            )
            .map((e) => e.x)
            .toList(),
        currentTetrisBlock,
        currentHighestTetrisBlock?.highestYValue ?? -4,
      );

      while (true) {
        final currentPushDirection =
            pushQueue[currentPushQueueIteration % pushQueue.length];
        ++currentPushQueueIteration;

        final willCollideWithRightObject =
            currentPushDirection == PushDirection.Right &&
                currentTetrisBlock.currentPosition.any(
                  (element) =>
                      element.x + 1 == rightWallX ||
                      occupiedSpaces.contains(
                        Coordinates(element.x + 1, element.y),
                      ),
                );
        final willCollideWithLeftObject =
            currentPushDirection == PushDirection.Left &&
                currentTetrisBlock.currentPosition.any(
                  (element) =>
                      element.x - 1 == leftWallX ||
                      occupiedSpaces.contains(
                        Coordinates(element.x - 1, element.y),
                      ),
                );

        //Check for collision with wall
        if (!willCollideWithRightObject && !willCollideWithLeftObject) {
          currentTetrisBlock.pushInDirection(currentPushDirection);
        }

        //There is something below blocking us
        if (currentTetrisBlock.currentPosition.any(
          (element) =>
              occupiedSpaces.contains(Coordinates(element.x, element.y - 1)),
        )) {
          break;
        }

        currentTetrisBlock.pushInDirection(PushDirection.Down);
      }

      if (currentHighestTetrisBlock == null ||
          currentTetrisBlock.highestYValue >
              currentHighestTetrisBlock.highestYValue) {
        heightHistory.add(currentTetrisBlock);
      }
      occupiedSpaces.addAll(currentTetrisBlock.currentPosition);

      states.add(currentState);

      ++currentBlockIteration;
    }

    //+4 to offset the fact that the bottom is at -4
    return heightHistory.last.highestYValue + 4;
  }

  int calculateHeightAt() {
    final numRocks = 1000000000000;

    List<State>? findPattern(List<State> list) {
      for (int i = 1; i <= list.length; i++) {
        // Check if the list can be divided into equal parts with a length of i
        if (list.length % i == 0) {
          // Divide the list into parts with a length of i
          List<List<State>> parts = List.generate(list.length ~/ i, (j) => list.skip(j * i).take(i).toList());

          // Check if all the parts are equal
          if (parts.every((part) => part == parts.first)) {
            return parts.first;
          }
        }
      }
      return null;
    }

    final test = findPattern(states)!;
    final numFullLoops = (numRocks - test.length) ~/ states.length;
    final offsetIntoLastLoop = ((numRocks - test.length) % states.length);
    final extraHeight = heightHistory[test.length + offsetIntoLastLoop].highestYValue;
    return states.last.height * numFullLoops + extraHeight;

    // Calculate the height at the target based on the number of loops and the height of the loop
/*    final numFullLoops = (numRocks - loopStart) ~/ loopLength;
    final offsetIntoLastLoop = ((numRocks - loopStart) % loopLength);
    final extraHeight = heightHistory[loopStart + offsetIntoLastLoop].highestYValue - heightBeforeLoop;
    return heightBeforeLoop + loopHeight * numFullLoops + extraHeight;*/
  }

  void drawTetrisBoard(TetrisBlock? currentTetrisBlock) {
    final linesToDraw = <String>[];

    for (var y = 10; y > -4; --y) {
      var yLine = "|";
      for (var x = 0; x < 7; ++x) {
        final objectAtCoords = occupiedSpaces.contains(Coordinates(x, y)) ||
            (currentTetrisBlock?.currentPosition.contains(Coordinates(x, y)) ??
                false);
        yLine += objectAtCoords ? '#' : '.';
      }
      linesToDraw.add(yLine + '|');
    }
    print(linesToDraw.join('\n'));
    print('|_______|');
  }
}

class State {
  final int pushIndex;
  final int blockIndex;
  final List<int> roof;
  final TetrisBlock block;
  final int height;

  State(this.pushIndex, this.blockIndex, this.roof, this.block, this.height);

  @override
  bool operator ==(Object other) {
    if (other is State) {
      return roof.equals(other.roof) &&
          blockIndex == other.blockIndex &&
          pushIndex == other.pushIndex &&
          block.baseShape.equals(other.block.baseShape);
    }
    return false;
  }

  @override
  int get hashCode {
    return pushIndex.hashCode ^ blockIndex.hashCode ^ roof.hashCode ^ block.hashCode;
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
            Coordinates(currentPositionOffset.x, currentPositionOffset.y - 1);
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
