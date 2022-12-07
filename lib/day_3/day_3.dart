import 'dart:ffi';
import 'dart:io';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

int getAlphabetValue(int matchingLetterUnicode) {
  final isCapitalLetter = matchingLetterUnicode < 91;
  final alphabetValue = isCapitalLetter
      ? matchingLetterUnicode - 38
      : matchingLetterUnicode - 96;

  return alphabetValue;
}

int day3() {
  final fileLines = getInputFileLines(3);

  var prioSum = 0;

  for (final line in fileLines) {
    final halfLineIndex = line.length ~/ 2;

    final firstComp = line.substring(0, halfLineIndex);
    final secondComp = line.substring(halfLineIndex, line.length);

    final matchingLetterUnicode = firstComp.codeUnits
        .firstWhere((element) => secondComp.codeUnits.contains(element));

    final alphabetValue = getAlphabetValue(matchingLetterUnicode);

    prioSum += alphabetValue;
  }

  day3Bonus(fileLines);
  return prioSum;
}

int day3Bonus(List<String> fileLines) {
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

    final alphabetValue = getAlphabetValue(matchingLetterUnicodeFirstGroup) + getAlphabetValue(matchingLetterUnicodeSecondGroup);

    badgeSum += alphabetValue;
  }

  return badgeSum;
}
