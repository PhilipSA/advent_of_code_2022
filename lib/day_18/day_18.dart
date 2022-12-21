import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day18() {
  final fileLines = getInputFileLines(18);

  final part1 = day18Read(fileLines, false);
  final part2 = day18Read(fileLines, true);
  print('Day 18 part 1: $part1 part 2: $part2');
}

int day18Read(List<String> fileLines, bool part2) {
  final cubes = fileLines.map((e) => Cube.fromFileLine(e)).toList();

  List<Day183D> generateSearchableSpace() {
    final objectsInSpace = <Day183D>[];

    for (var x = 0; x < 20; x++) {
      for (var y = 0; y < 20; y++) {
        for (var z = 0; z < 20; z++) {
          final cubeAtPosition = cubes.firstWhereOrNull(
              (element) => element.x == x && element.y == y && element.z == z,);
          if (cubeAtPosition != null) {
            objectsInSpace.add(cubeAtPosition);
          } else {
            objectsInSpace.add(EmptySpace(x, y, z));
          }
        }
      }
    }

    return objectsInSpace;
  }

  bool isExteriorCube(Cube start, List<Day183D> searchSpace) {
    final queue = PriorityQueue<Day183D>((a, b) => a.distanceTo(EmptySpace(0, 0, 0)).toInt() - b.distanceTo(EmptySpace(0, 0, 0)).toInt());
    // Create a set to store the visited cubes
    final visited = Set<Day183D>();
    // Add the start cube to the queue
    queue.add(start);

    // Loop until the queue is empty
    while (queue.isNotEmpty) {
      // Get the next cube from the queue
      final current = queue.removeFirst();
      // Mark the current cube as visited
      visited.add(current);
      // Check if the current cube is the goal
      if (current.x == 0 && current.y == 0 && current.z == 0) {
        return true;
      }

      // Get the neighbors of the current cube
      final neighbors =
          searchSpace.where((element) => current.isConnected(element) && element is EmptySpace);
      // Add the unvisited neighbors to the queue
      for (final neighbor in neighbors) {
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
    return false;
  }

  var exposedSides = 0;
  final searchSpaces = generateSearchableSpace();

  for (final cube in cubes) {
    if (part2) {
      final isExterior = isExteriorCube(cube, searchSpaces);
      if (!isExterior) {
        continue;
      }
    }

    exposedSides += 6 - cubes.where((cube2) => cube.isConnected(cube2)).length;
  }

  return exposedSides;
}

abstract class Day183D {
  final int x, y, z;

  Day183D(this.x, this.y, this.z);

  bool isConnected(Day183D otherObject) {
    return ((x - otherObject.x).abs() == 1 &&
            y == otherObject.y &&
            z == otherObject.z) ||
        (x == otherObject.x &&
            (y - otherObject.y).abs() == 1 &&
            z == otherObject.z) ||
        (x == otherObject.x &&
            y == otherObject.y &&
            (z - otherObject.z).abs() == 1);
  }

  double distanceTo(Day183D other) {
    return sqrt(
        pow(other.x - x, 2) + pow(other.y - y, 2) + pow(other.z - z, 2),);
  }
}

class EmptySpace extends Day183D {
  EmptySpace(super.x, super.y, super.z);
}

class Cube extends Day183D {
  Cube(super.x, super.y, super.z);

  factory Cube.fromFileLine(String fileLine) {
    final split = fileLine.split(',');
    return Cube(int.parse(split[0]), int.parse(split[1]), int.parse(split[2]));
  }
}
