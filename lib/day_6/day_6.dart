import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day6(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(6);
  final charArray = fileLines.first.split('');

  final part1 = _day6Read(charArray, 4);
  final part2 = _day6Read(charArray, 14);

  resultReporter.reportResult(6, part1, part2);
}

int _day6Read(List<String> charArray, int numberOfUniqueCharacters) {
  for (var i = 0; i < charArray.length; i++) {
    final currentBuffer = charArray.sublist(i, i + numberOfUniqueCharacters).toSet();

    if (currentBuffer.length == numberOfUniqueCharacters) {
      return i + numberOfUniqueCharacters;
    }
  }

  return 0;
}
