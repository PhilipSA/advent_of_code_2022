import 'dart:convert';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day13() {
  final fileLines = getInputFileLines(13);

  final part1 = day13Read(fileLines, false);
  final part2 = day13Read(fileLines, true);
  print("Day 13 part 1: $part1 part 2: $part2");
}

int day13Read(List<String> fileLines, bool isPart2) {
  final signalTracker = SignalTracker.createFromFileLines(fileLines);
  return isPart2
      ? signalTracker.findDecoderKey()
      : signalTracker.countPairsInRightOrder();
}

class SignalTracker {
  final List<ComparisonPair> pairs;

  SignalTracker(this.pairs);

  factory SignalTracker.createFromFileLines(List<String> fileLines) {
    final List<ComparisonPair> pairs = [];

    for (int i = 0; i < fileLines.length; i++) {
      pairs.add(ComparisonPair.createFromFileLine(
          fileLines.sublist(i, i + 2).toList()));
      i += 2;
    }

    return SignalTracker(pairs);
  }

  int findDecoderKey() {
    final two = JsonDecoder().convert('[[2]]');
    final six = JsonDecoder().convert('[[6]]');

    final sortedList = <dynamic>[
      ...pairs.map((e) => e.leftGroups),
      ...pairs.map((e) => e.rightGroups),
      two,
      six
    ];
    sortedList.sort(
        (a, b) => (ComparisonPair.isGroupInRightOrder(b, a) == true) ? 1 : -1);

    return (sortedList.indexOf(two) + 1) * (sortedList.indexOf(six) + 1);
  }

  int countPairsInRightOrder() {
    return pairs
        .where((e) =>
            ComparisonPair.isGroupInRightOrder(e.leftGroups, e.rightGroups) ==
            true)
        .map((n) => pairs.indexOf(n) + 1)
        .reduce((value, element) => value + element);
  }
}

class ComparisonPair {
  final List<dynamic> leftGroups;
  final List<dynamic> rightGroups;

  final String leftFileLine;
  final String rightFileLine;

  ComparisonPair(
      this.leftGroups, this.rightGroups, this.leftFileLine, this.rightFileLine);

  factory ComparisonPair.createFromFileLine(List<String> fileLines) {
    final leftEntries = fileLines[0];
    final rightEntries = fileLines[1];

    List<dynamic> getPairFromCurrentString(String fileLine) {
      return JsonDecoder().convert(fileLine);
    }

    return ComparisonPair(getPairFromCurrentString(leftEntries),
        getPairFromCurrentString(rightEntries), leftEntries, rightEntries);
  }

  static bool? isGroupInRightOrder(
      List<dynamic> leftPair, List<dynamic> rightPair) {
    bool? compareNumbers(int leftNumber, int rightNumber) {
      //Left entry is smaller
      if (leftNumber < rightNumber) {
        return true;
      } else if (leftNumber > rightNumber) {
        //Right entry is smaller
        return false;
      }
      return null;
    }

    for (int i = 0; i < max(leftPair.length, rightPair.length); i++) {
      final leftGroup = leftPair.elementAtOrNull(i);
      final rightGroup = rightPair.elementAtOrNull(i);

      //Left side ran out of elements
      if (leftGroup == null) {
        return true;
      }

      //Right side ran out of elements
      if (rightGroup == null) {
        return false;
      }

      if (leftGroup is int && rightGroup is int) {
        final compareNumbersResult = compareNumbers(leftGroup, rightGroup);

        if (compareNumbersResult != null) {
          return compareNumbersResult;
        }
        continue;
      }

      final result = isGroupInRightOrder(
          leftGroup is int ? <int>[leftGroup] : leftGroup,
          rightGroup is int ? <int>[rightGroup] : rightGroup);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
