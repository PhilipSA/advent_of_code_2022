import 'package:advent_of_code_2022/util/file_util.dart';

void day6() {
  final fileLines = getInputFileLines(6);
  final charArray = fileLines.first.split('');

  final part1 = day6Read(charArray, 4);
  final part2 = day6Read(charArray, 14);

  print("Day 6 part 1: $part1 part 2: $part2");
}

int day6Read(List<String> charArray, int numberOfUniqueCharacters) {
  for (int i = 0; i < charArray.length; i++) {
    final currentBuffer = charArray.sublist(i, i + numberOfUniqueCharacters).toSet();

    if (currentBuffer.length == numberOfUniqueCharacters) {
      return i + numberOfUniqueCharacters;
    }
  }

  return 0;
}
