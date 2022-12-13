import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day13() {
  final fileLines = getInputFileLines(13);

  final part1 = day13Read(fileLines);
  final part2 = day13Read(fileLines);
  print("Day 13 part 1: $part1 part 2: $part2");
}

int day13Read(List<String> fileLines) {
  final signalTracker = SignalTracker.createFromFileLines(fileLines);

  return signalTracker.countPairsInRightOrder();
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

  int countPairsInRightOrder() {
    return pairs
        .where((e) => e.isPairInRightOrder())
        .map((n) => pairs.indexOf(n) + 1)
        .reduce((value, element) => value + element);
  }
}

class ComparisonPair {
  final Map<int, List<int>> leftPair;
  final Map<int, List<int>> rightPair;

  ComparisonPair(this.leftPair, this.rightPair);

  factory ComparisonPair.createFromFileLine(List<String> fileLines) {
    final leftEntries = fileLines[0].split('');
    final rightEntries = fileLines[1].split('');

    Map<int, List<int>> getPairFromCurrentString(List<String> fileLine) {
      final Map<int, List<int>> entries = {};

      var currentLevel = 0;
      for (int i = 0; i < fileLine.length; i++) {
        final char = fileLine[i];
        if (char == '[' && fileLine.elementAtOrNull(i - 1) == '[') {
          --currentLevel;
        }
        else if (char == '[') {
          ++currentLevel;
        } else if (char == ']') {
          --currentLevel;
        } else if (char != ',') {
          final existingList = entries[currentLevel];
          if (existingList != null) {
            entries[currentLevel]?.add(int.parse(char));
          } else {
            entries[currentLevel] = <int>[int.parse(char)];
          }
        }
      }

      return entries;
    }

    return ComparisonPair(getPairFromCurrentString(leftEntries),
        getPairFromCurrentString(rightEntries));
  }

  bool isPairInRightOrder() {
    final List<bool> matchesList = [];

    for (final leftEntry in leftPair.entries) {
      if (leftEntry.value.length > (rightPair[leftEntry.key]?.length ?? 0)) {
        matchesList.add(false);
        continue;
      } else if (leftEntry.value.length <
          (rightPair[leftEntry.key]?.length ?? 0)) {
        matchesList.add(true);
        continue;
      }

      for (int i = 0; i < leftEntry.value.length; i++) {
        final subLeftEntry = leftEntry.value[i];
        if (subLeftEntry <= rightPair[leftEntry.key]![i]) {
          matchesList.add(true);
        } else {
          matchesList.add(false);
        }
      }
    }

    return matchesList.every((element) => element == true);
  }
}
