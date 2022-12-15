import 'dart:convert';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day14() {
  final fileLines = getInputFileLines(14);

  final part1 = day14Read(fileLines, false);
  final part2 = day14Read(fileLines, true);
  print("Day 14 part 1: $part1 part 2: $part2");
}

int day14Read(List<String> fileLines, bool part2) {
  final sandpit = Sandpit.putRocks(fileLines);

  if (part2) {
    sandpit.fillSandPit(500, 0);
    return sandpit.getNumberOfSandGrainsInPyramid();
  } else {
    sandpit.fillSandPit(500, 0);
    return sandpit.countGrainsOfSand;
  }
}

class Sandpit {
  final List<Element> objects;

  Element get lastSandGrain =>
      objects.lastWhere((element) => element.objectType == ObjectType.sand);
  int rockBottomY = 0;

  int get countGrainsOfSand =>
      objects.where((element) => element.objectType == ObjectType.sand).length;

  Sandpit(this.objects, this.rockBottomY);

  factory Sandpit.putRocks(List<String> fileLines) {
    final List<Element> objects = [];

    for (final line in fileLines) {
      final lineSplit = line.trim().split('->');

      for (int i = 0; i < lineSplit.length - 1; i++) {
        final currentLine = lineSplit[i].split(',');
        final nextLine = lineSplit[i + 1].split(',');

        final startObject = Element.rockFromString(currentLine);
        final endObject = Element.rockFromString(nextLine);

        //Left to right
        for (int x = startObject.x; x <= endObject.x; x++) {
          objects.add(Element(x, startObject.y, ObjectType.rock));
        }
        //Top to bottom
        for (int y = startObject.y; y <= endObject.y; y++) {
          objects.add(Element(startObject.x, y, ObjectType.rock));
        }

        //Right to left
        for (int x = startObject.x; x >= endObject.x; x--) {
          objects.add(Element(x, startObject.y, ObjectType.rock));
        }
        //Bottom to top
        for (int y = startObject.y; y >= endObject.y; y--) {
          objects.add(Element(startObject.x, y, ObjectType.rock));
        }
      }
    }

    return Sandpit(
        objects, objects.sorted((a, b) => a.y.compareTo(b.y)).last.y);
  }

  Element? getObjectAtCoordinates(int x, int y) {
    return objects.firstWhereOrNull((e) => e.x == x && e.y == y);
  }

  int getNumberOfSandGrainsInPyramid() {
    final totalSandGrainsInPyramid =
        (rockBottomY / 2) * (1 + (rockBottomY * 2 - 1));
    return totalSandGrainsInPyramid.toInt();
  }

  void fillSandPit(int sandX, int sandY) {
    MoveDirection? canMoveSandGrain(int x, int y) {
      //Sand grain is falling into the void
      if (y >= rockBottomY) {
        return MoveDirection.abyss;
      } else if (getObjectAtCoordinates(x, y + 1) == null) {
        return MoveDirection.down;
      } else if (getObjectAtCoordinates(x - 1, y + 1) == null) {
        return MoveDirection.downLeft;
      } else if (getObjectAtCoordinates(x + 1, y + 1) == null) {
        return MoveDirection.downRight;
      }
      return null;
    }

    while (canMoveSandGrain(sandX, sandY) != null) {
      final moveDirection = canMoveSandGrain(sandX, sandY);

      switch (moveDirection) {
        case MoveDirection.down:
          ++sandY;
          break;
        case MoveDirection.downLeft:
          ++sandY;
          --sandX;
          break;
        case MoveDirection.downRight:
          ++sandY;
          ++sandX;
          break;
        case MoveDirection.abyss:
          return;
        case null:
          break;
      }
    }
    objects.add(Element(sandX, sandY, ObjectType.sand));
    return fillSandPit(500, 0);
  }

  void drawSandPit() {
    final List<String> linesToDraw = [];

    for (int y = 0; y < rockBottomY + 5; ++y) {
      var yLine = "";
      for (int x = 420; x < 520; ++x) {
        final objectAtCoords = getObjectAtCoordinates(x, y);
        yLine += objectAtCoords != null
            ? objectAtCoords.objectType.drawingSymbol
            : '.';
      }
      linesToDraw.add(yLine);
    }
    print(linesToDraw.join('\n'));
  }
}

class Element {
  final int x;
  final int y;
  final ObjectType objectType;

  Element(this.x, this.y, this.objectType);

  Element.rockFromString(List<String> coordinates)
      : this(int.parse(coordinates[0]), int.parse(coordinates[1]),
            ObjectType.rock);
}

enum ObjectType {
  rock('#'),
  sand('o');

  final String drawingSymbol;

  const ObjectType(this.drawingSymbol);
}

enum MoveDirection { down, downLeft, downRight, abyss }
