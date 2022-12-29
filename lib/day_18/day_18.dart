import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/geometry.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day18(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(18);

  final part1 = _day18Read(fileLines, false);
  final part2 = _day18Read(fileLines, true);

  resultReporter.reportResult(18, part1, part2);
}

int _day18Read(List<String> fileLines, bool part2) {
  final cubes = fileLines.map((e) => _Cube.fromFileLine(e)).toList();

  List<ThreeDObject> generateSearchableSpace() {
    final objectsInSpace = <ThreeDObject>[];

    final cubesByX = cubes.sorted((a, b) => a.x.compareTo(b.x)).map((e) => e.x);
    final cubesByY = cubes.sorted((a, b) => a.y.compareTo(b.y)).map((e) => e.y);
    final cubesByZ = cubes.sorted((a, b) => a.z.compareTo(b.z)).map((e) => e.z);

    for (var x = cubesByX.first - 2; x < cubesByX.last + 2; x++) {
      for (var y = cubesByY.first - 2; y < cubesByY.last + 2; y++) {
        for (var z = cubesByZ.first - 2; z < cubesByZ.last + 2; z++) {
          final cubeAtPosition = cubes.firstWhereOrNull(
              (element) => element.x == x && element.y == y && element.z == z,);
          if (cubeAtPosition == null) {
            objectsInSpace.add(_EmptySpace(x, y, z));
          }
        }
      }
    }

    return objectsInSpace;
  }

  final inPathToGoal = Set<ThreeDObject>();
  final notInPathToGoal = Set<ThreeDObject>();

  bool isExteriorCube(ThreeDObject start, ThreeDObject goal, List<ThreeDObject> searchSpace) {
    final queue = PriorityQueue<ThreeDObject>((a, b) => a.distanceTo(goal).toInt() - b.distanceTo(goal).toInt());
    // Create a set to store the visited cubes
    final visited = Set<ThreeDObject>();
    // Add the start cube to the queue
    queue.add(start);

    // Loop until the queue is empty
    while (queue.isNotEmpty) {
      // Get the next cube from the queue
      final current = queue.removeFirst();
      // Mark the current cube as visited
      visited.add(current);
      // Check if the current cube is the goal
      if (current == goal || inPathToGoal.contains(current)) {
        inPathToGoal.addAll(visited);
        return true;
      } else if (notInPathToGoal.contains(current)) {
        break;
      }

      // Get the neighbors of the current cube
      final neighbors =
          searchSpace.where((element) => current.isConnected(element));
      // Add the unvisited neighbors to the queue
      for (final neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
    notInPathToGoal.addAll(visited);
    return false;
  }

  var exposedSides = 0;
  final searchSpaces = generateSearchableSpace();
  final goal = searchSpaces.firstWhere((element) => element.x == 0 && element.y == 0 && element.z == 0);
  final externalSearchSpaces = searchSpaces.where((element) => isExteriorCube(element, goal, searchSpaces));

  for (final cube in cubes) {
    if (part2) {
      exposedSides += externalSearchSpaces.where((element) => cube.isConnected(element)).length;
    }
    else {
      exposedSides += 6 - cubes
          .where((cube2) => cube.isConnected(cube2))
          .length;
    }
  }

  return exposedSides;
}

class _EmptySpace extends ThreeDObject {
  _EmptySpace(super.x, super.y, super.z);
}

class _Cube extends ThreeDObject {
  _Cube(super.x, super.y, super.z);

  factory _Cube.fromFileLine(String fileLine) {
    final split = fileLine.split(',');
    return _Cube(int.parse(split[0]), int.parse(split[1]), int.parse(split[2]));
  }
}
