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
    return sandpit.countGrainsOfSandInPyramid();
  } else {
    while (sandpit.dropGrainOfSand(500, 0)) {}

    //sandpit.drawSandPit();

    return sandpit.countGrainsOfSand;
  }
}

class Sandpit {
  final List<Object> objects;

  Object get rockBottom => objects.sorted((a, b) => a.y.compareTo(b.y)).last;

  int get countGrainsOfSand =>
      objects.where((element) => element.objectType == ObjectType.sand).length;

  Sandpit(this.objects);

  factory Sandpit.putRocks(List<String> fileLines) {
    final List<Object> objects = [];

    for (final line in fileLines) {
      final lineSplit = line.trim().split('->');

      for (int i = 0; i < lineSplit.length - 1; i++) {
        final currentLine = lineSplit[i].split(',');
        final nextLine = lineSplit[i + 1].split(',');

        final startObject = Object.rockFromString(currentLine);
        final endObject = Object.rockFromString(nextLine);

        //Left to right
        for (int x = startObject.x; x <= endObject.x; x++) {
          objects.add(Object(x, startObject.y, ObjectType.rock));
        }
        //Top to bottom
        for (int y = startObject.y; y <= endObject.y; y++) {
          objects.add(Object(startObject.x, y, ObjectType.rock));
        }

        //Right to left
        for (int x = startObject.x; x >= endObject.x; x--) {
          objects.add(Object(x, startObject.y, ObjectType.rock));
        }
        //Bottom to top
        for (int y = startObject.y; y >= endObject.y; y--) {
          objects.add(Object(startObject.x, y, ObjectType.rock));
        }
      }
    }

    return Sandpit(objects);
  }

  int countGrainsOfSandInPyramid() {
    int grainsOfSand = 1;

    for (int i = 1; i < rockBottom.y + 2; ++i) {
      grainsOfSand += i + 2;
    }

    return grainsOfSand - objects.length;
  }

  Object? getObjectAtCoordinates(int x, int y) {
    return objects.firstWhereOrNull((e) => e.x == x && e.y == y);
  }

  bool dropGrainOfSand(int sandX, int sandY) {
    MoveDirection? canMoveSandGrain(int x, int y) {
      //Sand grain is falling into the void
      if (y >= rockBottom.y) {
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
      final test = canMoveSandGrain(sandX, sandY);
      switch (test) {
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
          return false;
        case null:
          break;
      }
    }
    objects.add(Object(sandX, sandY, ObjectType.sand));
    return true;
  }

  void drawSandPit() {
    final List<String> linesToDraw = [];

    for (int y = 0; y < 200; ++y) {
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

class Object {
  final int x;
  final int y;
  final ObjectType objectType;

  Object(this.x, this.y, this.objectType);

  Object.rockFromString(List<String> coordinates)
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
