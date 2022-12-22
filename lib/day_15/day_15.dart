import 'dart:collection';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/geometry.dart';
import 'package:advent_of_code_2022/util/math.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day15(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(15);

  final part1 = _day15Read(fileLines, false);
  final part2 = _day15Read(fileLines, true);

  resultReporter.reportResult(15, part1, part2);
}

int _day15Read(List<String> fileLines, bool part2) {
  final antennaField = _AntennaField.populateFromFileLines(fileLines);
  final answer = part2
      ? antennaField.locateDistressBeacon()
      : antennaField.calculateMissingBeaconsAtRow(2000000);
  return answer;
}

class _AntennaField {
  final HashSet<TwoDObject> signalCatchers;

  _AntennaField(this.signalCatchers);

  List<_Sensor> get sensors => signalCatchers.whereType<_Sensor>().toList();

  factory _AntennaField.populateFromFileLines(List<String> fileLines) {
    final signalCatchers = HashSet<TwoDObject>();

    for (final fileLine in fileLines) {
      final splitOnType = fileLine.split(':');

      final beacon = Beacon(
        int.parse(splitOnType[1].split('x=')[1].split(',')[0]),
        int.parse(splitOnType[1].split('y=')[1]),
      );
      final sensor = _Sensor.withManhattanDistanceToBeacon(
        int.parse(splitOnType[0].split('x=')[1].split(',')[0]),
        int.parse(splitOnType[0].split('y=')[1]),
        beacon,
      );

      signalCatchers
        ..add(sensor)
        ..add(beacon);
    }

    return _AntennaField(signalCatchers);
  }

  int calculateMissingBeaconsAtRow(int rowIndex) {
    final sensorCoverageInRow = sensors
        .map((element) => element.getCoverageOnRow(rowIndex))
        .flattened
        .where((element) => element.y == rowIndex)
        .toSet();
    return sensorCoverageInRow.length;
  }

  int locateDistressBeacon() {
    final boundaryLimit = 4000000;

    for (final sensor in sensors) {
      final topY = sensor.y - sensor.manhattanDistanceToNearestBeacon - 1;
      final bottomY = sensor.y + sensor.manhattanDistanceToNearestBeacon + 1;
      for (var y = topY; y <= bottomY; y++) {
        final distanceToCenter = (sensor.y - y).abs();
        final leftX = sensor.x - sensor.manhattanDistanceToNearestBeacon - 1 + distanceToCenter;
        final rightX = sensor.x + sensor.manhattanDistanceToNearestBeacon + 1 - distanceToCenter;
        final leftPoint = TwoDObject(leftX, y);
        final rightPoint = TwoDObject(rightX, y);
        if (leftX < 0 || leftX > boundaryLimit || rightX < 0 || rightX > boundaryLimit) {
          continue;
        }
        if (y < 0 || y > boundaryLimit) {
          continue;
        }
        if (sensors.none((it) => it.manhattanDistanceToNearestBeacon >= manhattanDistance(it.x, it.y, leftPoint.x, leftPoint.y))) {
          return leftPoint.x * boundaryLimit + leftPoint.y;
        }
        if (sensors.none((it) => it.manhattanDistanceToNearestBeacon >= manhattanDistance(it.x, it.y, rightPoint.x, rightPoint.y))) {
          return rightPoint.x * boundaryLimit + rightPoint.y;
        }
      }
    }

    return 0;
  }

  void drawAntennaField() {
    final linesToDraw = <String>[];

    for (var y = -10; y < 30 + 5; ++y) {
      var yLine = "";
      for (var x = -20; x < 50; ++x) {
        final objectAtCoords = signalCatchers
            .firstWhereOrNull((element) => element.y == y && element.x == x);
        final hasSignalCoverage = sensors
            .map((e) => e.getCoverageOnRow(y))
            .flattened
            .firstWhereOrNull((element) => element.y == y && element.x == x);

        yLine += objectAtCoords != null
            ? objectAtCoords is Beacon
                ? 'B'
                : 'S'
            : hasSignalCoverage != null
                ? '#'
                : '.';
      }
      linesToDraw.add('$y ' + yLine);
    }
    print(linesToDraw.join('\n'));
  }
}

class _Sensor extends TwoDObject {
  final Beacon closestBeacon;
  final int manhattanDistanceToNearestBeacon;

  _Sensor(
    super.x,
    super.y,
    this.closestBeacon,
    this.manhattanDistanceToNearestBeacon,
  );

  factory _Sensor.withManhattanDistanceToBeacon(
    final int x,
    final int y,
    Beacon closestBeacon,
  ) {
    final manhattanDistanceToNearestBeacon =
        manhattanDistance(x, y, closestBeacon.x, closestBeacon.y);
    return _Sensor(x, y, closestBeacon, manhattanDistanceToNearestBeacon);
  }

  List<TwoDObject> getCoverageOnRow(int row) {
    final coordinates = <TwoDObject>[];

    for (var scanX = x - manhattanDistanceToNearestBeacon;
        scanX <= x + manhattanDistanceToNearestBeacon;
        scanX++) {
      final distance = manhattanDistance(x, y, scanX, row);
      if (distance <= manhattanDistanceToNearestBeacon &&
          !(scanX == x && row == y) &&
          !(scanX == closestBeacon.x && row == closestBeacon.y)) {
        coordinates.add(TwoDObject(scanX, row));
      }
    }
    return coordinates;
  }
}

class Beacon extends TwoDObject {
  Beacon(super.x, super.y);
}
