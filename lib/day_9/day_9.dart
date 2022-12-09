import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';

void day9() {
  final fileLines = getInputFileLines(9);

  final part1 = day9Read(
    fileLines,
    MovementTracker(
      List.generate(2, (index) => RopePiece(0, 0)),
    ),
  ).uniqueVisitedLocations.length;
  final part2 = day9Read(
    fileLines,
    MovementTracker(
      List.generate(10, (index) => RopePiece(0, 0)),
    ),
  ).uniqueVisitedLocations.length;

  print("Day 9 part 1: $part1 part 2: $part2");
}

MovementTracker day9Read(
    List<String> fileLines, MovementTracker movementTracker) {

  for (final line in fileLines) {
    final lineSplit = line.split(' ');

    late MovementDirection movementDirection;
    switch (lineSplit[0]) {
      case 'U':
        movementDirection = MovementDirection.up;
        break;
      case 'D':
        movementDirection = MovementDirection.down;
        break;
      case 'L':
        movementDirection = MovementDirection.left;
        break;
      case 'R':
        movementDirection = MovementDirection.right;
        break;
    }

    movementTracker.moveHead(movementDirection, int.parse(lineSplit[1]));
  }

  return movementTracker;
}

enum MovementDirection {
  up('u'),
  down('d'),
  left('l'),
  right('r');

  final String letter;

  const MovementDirection(this.letter);
}

class MovementTracker {
  final List<RopePiece> ropePieces;

  RopePiece get tail => ropePieces.last;

  RopePiece get head => ropePieces.first;

  final List<Map<int, int>> uniqueVisitedLocations = [
    {0: 0}
  ];

  MovementTracker(this.ropePieces);

  void moveHead(MovementDirection moveDirection, int amountOfTimes) {
    for (int i = 0; i < amountOfTimes; i++) {
      switch (moveDirection) {
        case MovementDirection.up:
          ++head.y;
          break;
        case MovementDirection.down:
          --head.y;
          break;
        case MovementDirection.left:
          --head.x;
          break;
        case MovementDirection.right:
          ++head.x;
          break;
      }

      for (int i = 0; i < ropePieces.length; i++) {
        final currentRopePiece = ropePieces[i];

        if (currentRopePiece == head) {
          continue;
        }

        if (currentRopePiece.compareDistance(ropePieces[i - 1]) > 1) {
          moveRopePiece(ropePieces[i - 1], currentRopePiece);
        }

        if (currentRopePiece == tail) {
          if (!uniqueVisitedLocations.any((element) => element[tail.x] == tail.y)) {
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
      tail.x += xDiff.abs() == 2 ? stepX : xDiff;
      tail.y += yDiff.abs() == 2 ? stepY : yDiff;
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
