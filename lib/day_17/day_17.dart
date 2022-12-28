import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/generic.dart';
import 'package:advent_of_code_2022/util/geometry.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day17(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(17);

  final part1 = _day17Read(fileLines, false);
  final part2 = _day17Read(fileLines, true);

  resultReporter.reportResult(17, part1, part2);
}

int _day17Read(List<String> fileLines, bool part2) {
  final tetrisBoard = _TetrisBoard.createFromFileLine(fileLines);
  final height = tetrisBoard.runTetrisGame(part2 ? 5000 : 2023);
  return height;
}

class _TetrisBoard {
  final List<_TetrisBlock> availableTetrisBlocks = [];
  final List<_PushDirection> pushQueue = [];
  _TetrisBlock? currentHighestTetrisBlock;
  final List<TwoDObject> occupiedSpaces = List.generate(
    8,
    (i) => TwoDObject(i, -4),
  );
  final List<_State> states = [];

  final rightWallX = 7;
  final leftWallX = -1;

  _TetrisBoard();

  factory _TetrisBoard.createFromFileLine(List<String> fileLines) {
    final tetrisBoard = _TetrisBoard();

    // #### shape
    tetrisBoard.availableTetrisBlocks.add(
      _TetrisBlock([
        TwoDObject(0, 0),
        TwoDObject(1, 0),
        TwoDObject(2, 0),
        TwoDObject(3, 0)
      ]),
    );
    /*.#.
      ###
      .#. shape*/

    tetrisBoard.availableTetrisBlocks.add(
      _TetrisBlock([
        TwoDObject(1, 0),
        TwoDObject(0, 1),
        TwoDObject(1, 1),
        TwoDObject(2, 1),
        TwoDObject(1, 2),
      ]),
    );
    /*..#
      ..#
      ### shape*/
    tetrisBoard.availableTetrisBlocks.add(
      _TetrisBlock([
        TwoDObject(0, 0),
        TwoDObject(1, 0),
        TwoDObject(2, 0),
        TwoDObject(2, 1),
        TwoDObject(2, 2),
      ]),
    );
    /*#
      #
      #
      # shape*/
    tetrisBoard.availableTetrisBlocks.add(
      _TetrisBlock([
        TwoDObject(0, 0),
        TwoDObject(0, 1),
        TwoDObject(0, 2),
        TwoDObject(0, 3),
      ]),
    );
    /*##
      ## shape*/
    tetrisBoard.availableTetrisBlocks.add(
      _TetrisBlock([
        TwoDObject(0, 0),
        TwoDObject(1, 0),
        TwoDObject(0, 1),
        TwoDObject(1, 1),
      ]),
    );

    tetrisBoard.pushQueue.addAll(
      fileLines.first
          .split('')
          .map((e) => e == '<' ? _PushDirection.Left : _PushDirection.Right),
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

      currentTetrisBlock.currentPositionOffset = TwoDObject(
        2,
        currentHighestTetrisBlock != null
            ? currentHighestTetrisBlock!.highestYValue + 4
            : 0,
      );

      final currentState = _State(
        currentPushQueueIteration % pushQueue.length,
        currentBlockIteration % availableTetrisBlocks.length,
        states
            .map((e) => e.block)
            .skip(max(0, states.length - 20))
            .take(20)
            .toList(),
        currentTetrisBlock,
        currentHighestTetrisBlock?.highestYValue ?? -4,
      );

      if (states.contains(currentState)) {
        final prevState = states[states.indexOf(currentState)];
        final cyclePeriod = currentBlockIteration - states.indexOf(currentState);
        if (currentBlockIteration % cyclePeriod == 1000000000000 % cyclePeriod) {
          final cycleHeight = currentState.height - prevState.height;
          final remainingRocks = 1000000000000 - states.length;
          final cyclesRemaining = remainingRocks ~/ cyclePeriod;
          return currentState.height + 4 + (cycleHeight * cyclesRemaining);
        }
      }

      while (true) {
        final currentPushDirection =
            pushQueue[currentPushQueueIteration % pushQueue.length];
        ++currentPushQueueIteration;

        final willCollideWithRightObject =
            currentPushDirection == _PushDirection.Right &&
                currentTetrisBlock.currentPosition.any(
                  (element) =>
                      element.x + 1 == rightWallX ||
                      occupiedSpaces.contains(
                        TwoDObject(element.x + 1, element.y),
                      ),
                );
        final willCollideWithLeftObject =
            currentPushDirection == _PushDirection.Left &&
                currentTetrisBlock.currentPosition.any(
                  (element) =>
                      element.x - 1 == leftWallX ||
                      occupiedSpaces.contains(
                        TwoDObject(element.x - 1, element.y),
                      ),
                );

        //Check for collision with wall
        if (!willCollideWithRightObject && !willCollideWithLeftObject) {
          currentTetrisBlock.pushInDirection(currentPushDirection);
        }

        //There is something below blocking us
        if (currentTetrisBlock.currentPosition.any(
          (element) =>
              occupiedSpaces.contains(TwoDObject(element.x, element.y - 1)),
        )) {
          break;
        }

        currentTetrisBlock.pushInDirection(_PushDirection.Down);
      }

      if (currentHighestTetrisBlock == null ||
          currentTetrisBlock.highestYValue >
              currentHighestTetrisBlock!.highestYValue) {
        currentHighestTetrisBlock = currentTetrisBlock;
      }
      occupiedSpaces.addAll(currentTetrisBlock.currentPosition);

      states.add(currentState);

      ++currentBlockIteration;
    }

    //+4 to offset the fact that the bottom is at -4
    return currentHighestTetrisBlock!.highestYValue + 4;
  }

  int calculateHeightAt() {
    List<_State> findCommonSequentialPattern(List<_State> list) {
      final pattern = <_State>[];
      for (var i = 0; i < list.length; i++) {
        final current = list[i];
        if (pattern.contains(current)) {
          continue;
        }
        final next = list[i + 1];
        if (current == next) {
          pattern.add(current);
          var patternRepeated = true;
          for (var k = i + 2; k < list.length; k++) {
            final next = list[k];
            if (next != current) {
              patternRepeated = false;
              break;
            }
          }
          if (!patternRepeated) {
            break;
          }
        }
      }
      return pattern;
    }

    final numRocks = 1000000000000;
    final commonPattern = findCommonSequentialPattern(states);
    final commonPatternList = commonPattern;

    final cyclePeriod = commonPatternList.length;
    final cycleHeight =
        commonPatternList.last.height - commonPatternList.first.height;
    final remainingRocks = numRocks - commonPatternList.length;
    final cyclesRemaining = remainingRocks ~/ cyclePeriod;
    return commonPatternList.first.height + (cycleHeight * cyclesRemaining);
  }

  void drawTetrisBoard(_TetrisBlock? currentTetrisBlock) {
    final linesToDraw = <String>[];

    for (var y = 10; y > -4; --y) {
      var yLine = '|';
      for (var x = 0; x < 7; ++x) {
        final objectAtCoords = occupiedSpaces.contains(TwoDObject(x, y)) ||
            (currentTetrisBlock?.currentPosition.contains(TwoDObject(x, y)) ??
                false);
        yLine += objectAtCoords ? '#' : '.';
      }
      linesToDraw.add(yLine + '|');
    }
    print(linesToDraw.join('\n'));
    print('|_______|');
  }
}

class _State {
  final int pushIndex;
  final int blockIndex;
  final List<_TetrisBlock> last500Blocks;
  final _TetrisBlock block;
  final int height;

  _State(this.pushIndex, this.blockIndex, this.last500Blocks, this.block,
      this.height);

  @override
  bool operator ==(Object other) {
    if (other is _State) {
      return last500Blocks.equals(other.last500Blocks) &&
          blockIndex == other.blockIndex &&
          pushIndex == other.pushIndex &&
          block.baseShape.equals(other.block.baseShape);
    }
    return false;
  }

  @override
  int get hashCode {
    return pushIndex.hashCode ^
        blockIndex.hashCode ^
        last500Blocks.hashCode ^
        block.hashCode;
  }
}

class _TetrisBlock {
  final List<TwoDObject> baseShape;
  TwoDObject currentPositionOffset = TwoDObject(0, 0);

  List<TwoDObject> get currentPosition => baseShape
      .map(
        (e) => TwoDObject(
          e.x + currentPositionOffset.x,
          e.y + currentPositionOffset.y,
        ),
      )
      .toList();

  int get lowestYValue =>
      currentPosition.sorted((a, b) => a.y.compareTo(b.y)).first.y;

  int get highestYValue =>
      currentPosition.sorted((a, b) => a.y.compareTo(b.y)).last.y;

  _TetrisBlock(this.baseShape);

  void pushInDirection(_PushDirection pushDirection) {
    switch (pushDirection) {
      case _PushDirection.Down:
        currentPositionOffset =
            TwoDObject(currentPositionOffset.x, currentPositionOffset.y - 1);
        break;
      case _PushDirection.Left:
        currentPositionOffset =
            TwoDObject(currentPositionOffset.x - 1, currentPositionOffset.y);
        break;
      case _PushDirection.Right:
        currentPositionOffset =
            TwoDObject(currentPositionOffset.x + 1, currentPositionOffset.y);
        break;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is _TetrisBlock) {
      return baseShape.equals(other.baseShape) &&
          currentPositionOffset == other.currentPositionOffset;
    }
    return false;
  }

  @override
  int get hashCode {
    return baseShape.hashCode ^ currentPositionOffset.hashCode;
  }
}

enum _PushDirection { Left, Right, Down }
