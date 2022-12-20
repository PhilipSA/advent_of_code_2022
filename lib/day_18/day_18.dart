import 'package:advent_of_code_2022/util/file_util.dart';

void day18() {
  final fileLines = getInputFileLines(18);

  final part1 = day18Read(fileLines, false);
  final part2 = day18Read(fileLines, true);
  print('Day 18 part 1: $part1 part 2: $part2');
}

int day18Read(List<String> fileLines, bool part2) {
  final cubes = fileLines.map((e) => Cube.fromFileLine(e));

  var exposedSides = 0;

  for (final cube in cubes) {
    exposedSides += 6 -
        cubes
            .where((cube2) => cube.isConnected(cube2))
            .length;
  }

  return exposedSides;
}

class Cube {
  final int x,y,z;

  Cube(this.x, this.y, this.z);

  factory Cube.fromFileLine(String fileLine) {
    final split = fileLine.split(',');
    return Cube(int.parse(split[0]), int.parse(split[1]), int.parse(split[2]));
  }

  bool isConnected(Cube otherCube) {
    return ((x - otherCube.x).abs() == 1 && y == otherCube.y && z == otherCube.z) ||
        (x == otherCube.x && (y - otherCube.y).abs() == 1 && z == otherCube.z) ||
        (x == otherCube.x && y == otherCube.y && (z - otherCube.z).abs() == 1);
  }
}
