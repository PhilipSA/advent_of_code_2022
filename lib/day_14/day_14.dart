import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/geometry.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day14(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(14);

  final part1 = _day14Read(fileLines, false);
  final part2 = _day14Read(fileLines, true);

  resultReporter.reportResult(14, part1, part2);
}

int _day14Read(List<String> fileLines, bool part2) {
  final sandpit = _Sandpit.putRocks(fileLines);

  if (part2) {
    return sandpit.getNumberOfSandGrainsInPyramid();
  } else {
    sandpit.fillSandPit(500, 0);
    return sandpit.countGrainsOfSand;
  }
}

class _Sandpit {
  final HashSet<_Element> objects;

  _Element get lastSandGrain =>
      objects.lastWhere((element) => element.objectType == _ObjectType.sand);
  int rockBottomY = 0;

  int get countGrainsOfSand =>
      objects.where((element) => element.objectType == _ObjectType.sand).length;

  _Sandpit(this.objects, this.rockBottomY);

  factory _Sandpit.putRocks(List<String> fileLines) {
    final objects = HashSet<_Element>();

    for (final line in fileLines) {
      final lineSplit = line.trim().split('->');

      for (var i = 0; i < lineSplit.length - 1; i++) {
        final currentLine = lineSplit[i].split(',');
        final nextLine = lineSplit[i + 1].split(',');

        final startObject = _Element.rockFromString(currentLine);
        final endObject = _Element.rockFromString(nextLine);

        void drawInversePyramid(
          int startX,
          int endX,
          int baseWidth,
          int currentY,
        ) {
          for (var i = 0; i <= baseWidth; i++) {
            for (var k = i; k <= baseWidth - i; k++) {
              objects.add(
                _Element(
                  startX + k,
                  currentY + i,
                  i == 0 ? _ObjectType.rock : _ObjectType.stalagmite,
                ),
              );
            }
          }
        }

        //Generate these as inversed pyramids for part 2
        drawInversePyramid(
          min(startObject.x, endObject.x),
          max(startObject.x, endObject.x),
          (startObject.x - endObject.x).abs(),
          startObject.y,
        );

        //Top to bottom
        for (var y = startObject.y; y <= endObject.y; y++) {
          objects.add(_Element(startObject.x, y, _ObjectType.rock));
        }
        //Bottom to top
        for (var y = startObject.y; y >= endObject.y; y--) {
          objects.add(_Element(startObject.x, y, _ObjectType.rock));
        }
      }
    }

    final lowestX = objects.sorted((a, b) => a.x.compareTo(b.x)).first.x;
    final highestX = objects.sorted((a, b) => a.x.compareTo(b.x)).last.x;
    final highestY = objects
        .where((element) => element.objectType == _ObjectType.rock)
        .sorted((a, b) => a.y.compareTo(b.y))
        .last
        .y;

    for (var y = 0; y < highestY; ++y) {
      for (var x = lowestX; x <= highestX; ++x) {
        final object = objects.firstWhereOrNull((e) => e.x == x && e.y == y);
        if (object != null) {
          continue;
        } else if (objects.firstWhereOrNull((e) => e.x == x && e.y == y - 1) !=
                null &&
            objects.firstWhereOrNull((e) => e.x == x + 1 && e.y == y - 1) !=
                null &&
            objects.firstWhereOrNull((e) => e.x == x - 1 && e.y == y - 1) !=
                null) {
          objects.add(_Element(x, y, _ObjectType.stalagmite));
        }
      }
    }

    return _Sandpit(objects, highestY);
  }

  _Element? getObjectAtCoordinates(int x, int y) {
    return objects.firstWhereOrNull((e) => e.x == x && e.y == y);
  }

  int getNumberOfSandGrainsInPyramid() {
    rockBottomY += 2;

    var totalSandGrainsInPyramid =
        (rockBottomY / 2) * (1 + (rockBottomY * 2 - 1));

    totalSandGrainsInPyramid -=
        objects.where((element) => element.y < rockBottomY).length;

    return totalSandGrainsInPyramid.toInt();
  }

  void fillSandPit(int sandX, int sandY) {
    _MoveDirection? canMoveSandGrain(int x, int y) {
      //Sand grain is falling into the void
      if (y >= rockBottomY) {
        return _MoveDirection.abyss;
      } else if (getObjectAtCoordinates(x, y + 1) == null) {
        return _MoveDirection.down;
      } else if (getObjectAtCoordinates(x - 1, y + 1) == null) {
        return _MoveDirection.downLeft;
      } else if (getObjectAtCoordinates(x + 1, y + 1) == null) {
        return _MoveDirection.downRight;
      }
      return null;
    }

    while (canMoveSandGrain(sandX, sandY) != null) {
      final moveDirection = canMoveSandGrain(sandX, sandY);

      switch (moveDirection) {
        case _MoveDirection.down:
          ++sandY;
          break;
        case _MoveDirection.downLeft:
          ++sandY;
          --sandX;
          break;
        case _MoveDirection.downRight:
          ++sandY;
          ++sandX;
          break;
        case _MoveDirection.abyss:
          return;
        case null:
          break;
      }
    }
    objects.add(_Element(sandX, sandY, _ObjectType.sand));
    return fillSandPit(500, 0);
  }

  void drawSandPit() {
    final linesToDraw = <String>[];

    for (var y = 0; y < rockBottomY + 5; ++y) {
      var yLine = "";
      for (var x = 420; x < 520; ++x) {
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

class _Element extends TwoDObject {
  final _ObjectType objectType;

  _Element(super.x, super.y, this.objectType);

  _Element.rockFromString(List<String> coordinates)
      : this(
          int.parse(coordinates[0]),
          int.parse(coordinates[1]),
          _ObjectType.rock,
        );
}

enum _ObjectType {
  rock('#'),
  stalagmite('|'),
  sand('o');

  final String drawingSymbol;

  const _ObjectType(this.drawingSymbol);
}

enum _MoveDirection { down, downLeft, downRight, abyss }
