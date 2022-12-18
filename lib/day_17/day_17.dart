import 'package:advent_of_code_2022/util/file_util.dart';

void day17() {
  final fileLines = getInputFileLines(17);

  final part1 = day17Read(fileLines, false);
  final part2 = day17Read(fileLines, true);
  print('Day 17 part 1: $part1 part 2: $part2');
}

int day17Read(List<String> fileLines, bool part2) {

  return 0;
}

class Coordinates {
  int x;
  int y;

  Coordinates(this.x, this.y);
}

class TetrisBlock {
  final List<Coordinates> currentPosition;

  TetrisBlock(this.currentPosition);
}

enum PushDirections {
  Left,
  Right
}