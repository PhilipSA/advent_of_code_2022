import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day3(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(3);

  var prioSum = 0;

  for (final line in fileLines) {
    final halfLineIndex = line.length ~/ 2;

    final firstComp = line.substring(0, halfLineIndex);
    final secondComp = line.substring(halfLineIndex, line.length);

    final matchingLetterUnicode = firstComp.codeUnits
        .firstWhere((element) => secondComp.codeUnits.contains(element));

    final alphabetValue = _getAlphabetValue(matchingLetterUnicode);

    prioSum += alphabetValue;
  }

  resultReporter.reportResult(3, prioSum, _day3Bonus(fileLines));
}

int _day3Bonus(List<String> fileLines) {
  final duoGroups = fileLines.slices(6);

  var badgeSum = 0;

  for (final duoGroup in duoGroups) {
    final firstGroup = duoGroup.take(3).toList();
    final secondGroup = duoGroup.sublist(3, 6);

    foldGroup(List<String> group){
      return group.fold<Set>(
          group.first.codeUnits.toSet(),
              (a, b) => a.intersection(b.codeUnits.toSet())).first;
    }

    final matchingLetterUnicodeFirstGroup = foldGroup(firstGroup);
    final matchingLetterUnicodeSecondGroup = foldGroup(secondGroup);

    final alphabetValue = _getAlphabetValue(matchingLetterUnicodeFirstGroup) + _getAlphabetValue(matchingLetterUnicodeSecondGroup);

    badgeSum += alphabetValue;
  }

  return badgeSum;
}

int _getAlphabetValue(int matchingLetterUnicode) {
  final isCapitalLetter = matchingLetterUnicode < 91;
  final alphabetValue = isCapitalLetter
      ? matchingLetterUnicode - 38
      : matchingLetterUnicode - 96;

  return alphabetValue;
}
