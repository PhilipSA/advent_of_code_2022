import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';
import 'package:complex/complex.dart';

void day22(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(22);

  final part1 = _day22Read(fileLines, false);
  final part2 = _day22Read(fileLines, true);

  resultReporter.reportResult(22, part1, part2);
}

num _day22Read(List<String> fileLines, bool part2) {
  final map = Map<Complex, _Point>();

  for (var i = 0; i < fileLines.length; ++i) {
    final line = fileLines[i];

    if (line.isEmpty) {
      break;
    }

    map.addEntries(
      line.split('').mapIndexed(
        (index, element) {
          final coords = Complex(index.toDouble(), i.toDouble());
          return MapEntry(
            coords,
            _Point(
              coords,
              element == ' '
                  ? _NodeType.space
                  : element == '.'
                      ? _NodeType.dot
                      : _NodeType.wall,
            ),
          );
        },
      ),
    );
  }

  if (part2) {
    final filterOutSpaces = map.values.whereNot((element) => element.nodeType == _NodeType.space);

    final height = filterOutSpaces.map((e) => e.coords.imaginary).max + 1;
    final width = filterOutSpaces.map((e) => e.coords.real).max + 1;

    final cubeDimension = max(height, width) % 6;

    for (var y = 0.0; y < height; ++y) {
      final currentCubeYIndex = y % height;

      for (var x = 0.0; x < width; ++x) {
        final currentCubeXIndex = x % (width / cubeDimension);
        final matchingCoordinate = filterOutSpaces.firstWhereOrNull((element) => element.coords == Complex(x, y));

        if (matchingCoordinate != null) {
          matchingCoordinate.cubeSurfaceIndex = (currentCubeYIndex + currentCubeXIndex).toInt();
        }
      }
    }
  }

  List<_Instruction> getInstructions() {
    final instructionsString = 'R' + fileLines.last;
    final list = <_Instruction>[];
    final instructionsSplit =
        instructionsString.replaceAllMapped(RegExp(r'\d+'), (match) {
      return ' ${match.group(0)} ';
    }).split(' ');
    for (var i = 0; i < instructionsSplit.length; i += 2) {
      final direction = instructionsSplit[i];
      final numbers =
          int.tryParse(instructionsSplit.elementAtOrNull(i + 1) ?? '');

      if (numbers != null) {
        list.add(_Instruction(numbers, direction));
      }
    }
    return list;
  }

  final instructions = getInstructions();

  var currentDirection = Complex(1, 0); // facing East
  var currentPosition = map.entries
      .firstWhere((element) => element.value.nodeType == _NodeType.dot)
      .value
      .coords;

  Complex rotateDirection(Complex direction, int rotationDirection) {
    return direction * Complex(0, rotationDirection.toDouble());
  }

  instructions.forEachIndexed((index, element) {
    if (index != 0) {
      currentDirection =
          rotateDirection(currentDirection, element.direction == 'R' ? 1 : -1);
    }

    for (var i = 0; i < element.steps; ++i) {
      final newPosition = currentPosition + currentDirection;

      if (part2) {

      } else if (map[newPosition] == null ||
          map[newPosition]!.nodeType == _NodeType.space) {
        _Point? getNextPositionX(int Function(double, double) comparator) {
          final newPosition = map.values
              .where((element) =>
                  element.coords.imaginary == currentPosition.imaginary &&
                  element.nodeType != _NodeType.space)
              .sorted((a, b) => comparator(a.coords.real, b.coords.real))
              .first;

          if (newPosition.nodeType != _NodeType.wall) {
            return newPosition;
          }
          return null;
        }

        _Point? getNextPositionY(int Function(double, double) comparator) {
          final newPosition = map.values
              .where((element) =>
                  element.coords.real == currentPosition.real &&
                  element.nodeType != _NodeType.space)
              .sorted(
                  (a, b) => comparator(a.coords.imaginary, b.coords.imaginary))
              .first;

          if (newPosition.nodeType != _NodeType.wall) {
            return newPosition;
          }
          return null;
        }

        //Going left or right
        if (currentDirection.real == 1 || currentDirection.real == -1) {
          final newPosition = currentDirection.real == 1
              ? getNextPositionX((a, b) => a.compareTo(b))
              : getNextPositionX((a, b) => b.compareTo(a));

          if (newPosition != null) {
            currentPosition = newPosition.coords;
          }
        }
        //Up or down
        else if (currentDirection.imaginary == 1 ||
            currentDirection.imaginary == -1) {
          final newPosition = currentDirection.imaginary == 1
              ? getNextPositionY((a, b) => a.compareTo(b))
              : getNextPositionY((a, b) => b.compareTo(a));

          if (newPosition != null) {
            currentPosition = newPosition.coords;
          }
        }
      } else if (map[newPosition]!.nodeType == _NodeType.dot) {
        currentPosition = newPosition;
      }
    }
  });

  return 1000 * (currentPosition.imaginary + 1) +
      4 * (currentPosition.real + 1) +
      4 *
          (currentDirection.real == 1
              ? 0
              : currentDirection.imaginary == 1
                  ? 1
                  : currentDirection.real == -1
                      ? 2
                      : 3);
}

class _Point {
  final Complex coords;
  final _NodeType nodeType;
  late int cubeSurfaceIndex;

  _Point(this.coords, this.nodeType);
}

enum _NodeType { dot, wall, space }

class _Instruction {
  final int steps;
  final String direction;

  _Instruction(this.steps, this.direction);
}
