import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day9(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(9);

  final part1 = _day9Read(
    fileLines,
    _MovementTracker(
      List.generate(2, (index) => RopePiece(0, 0)),
    ),
  ).uniqueVisitedLocations.length;
  final part2 = _day9Read(
    fileLines,
    _MovementTracker(
      List.generate(10, (index) => RopePiece(0, 0)),
    ),
  ).uniqueVisitedLocations.length;

  resultReporter.reportResult(9, part1, part2);
}

_MovementTracker _day9Read(
  List<String> fileLines,
  _MovementTracker movementTracker,
) {
  for (final line in fileLines) {
    final lineSplit = line.split(' ');

    late _MovementDirection movementDirection;
    switch (lineSplit[0]) {
      case 'U':
        movementDirection = _MovementDirection.up;
        break;
      case 'D':
        movementDirection = _MovementDirection.down;
        break;
      case 'L':
        movementDirection = _MovementDirection.left;
        break;
      case 'R':
        movementDirection = _MovementDirection.right;
        break;
    }

    movementTracker.moveHead(movementDirection, int.parse(lineSplit[1]));
  }

  return movementTracker;
}

enum _MovementDirection {
  up('u'),
  down('d'),
  left('l'),
  right('r');

  final String letter;

  const _MovementDirection(this.letter);
}

class _MovementTracker {
  final List<RopePiece> ropePieces;

  RopePiece get tail => ropePieces.last;

  RopePiece get head => ropePieces.first;

  final List<Map<int, int>> uniqueVisitedLocations = [
    {0: 0}
  ];

  _MovementTracker(this.ropePieces);

  void moveHead(_MovementDirection moveDirection, int amountOfTimes) {
    for (var i = 0; i < amountOfTimes; i++) {
      switch (moveDirection) {
        case _MovementDirection.up:
          ++head.y;
          break;
        case _MovementDirection.down:
          --head.y;
          break;
        case _MovementDirection.left:
          --head.x;
          break;
        case _MovementDirection.right:
          ++head.x;
          break;
      }

      for (var i = 0; i < ropePieces.length; i++) {
        final currentRopePiece = ropePieces[i];

        if (currentRopePiece == head) {
          continue;
        }

        if (currentRopePiece.compareDistance(ropePieces[i - 1]) > 1) {
          moveRopePiece(ropePieces[i - 1], currentRopePiece);
        }

        if (currentRopePiece == tail) {
          if (!uniqueVisitedLocations
              .any((element) => element[tail.x] == tail.y)) {
            uniqueVisitedLocations.add({tail.x: tail.y});
          }
        }
      }
    }
  }

  void moveRopePiece(RopePiece head, RopePiece tail) {
    final xDiff = head.x - tail.x;
    final yDiff = head.y - tail.y;
    final stepX = xDiff < 0 ? xDiff + 1 : xDiff - 1;
    final stepY = yDiff < 0 ? yDiff + 1 : yDiff - 1;

    if (tail.x != head.x && head.y != tail.y) {
      tail
        ..x += xDiff.abs() == 2 ? stepX : xDiff
        ..y += yDiff.abs() == 2 ? stepY : yDiff;
    } else {
      if (tail.x != head.x) {
        tail.x += stepX;
      }
      if (tail.y != head.y) {
        tail.y += stepY;
      }
    }
  }
}

class RopePiece {
  int x;
  int y;

  RopePiece(this.x, this.y);

  int compareDistance(RopePiece otherRopePiece) {
    return max((x - otherRopePiece.x).abs(), (y - otherRopePiece.y).abs());
  }
}
