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
  final Map<int, List<String>> leftPair;
  final Map<int, List<String>> rightPair;

  ComparisonPair(this.leftPair, this.rightPair);

  factory ComparisonPair.createFromFileLine(List<String> fileLines) {
    final leftEntries = fileLines[0].split('');
    final rightEntries = fileLines[1].split('');

    Map<int, List<String>> getPairFromCurrentString(List<String> fileLine) {
      final Map<int, List<String>> entries = {};

      var currentLevel = 0;
      var currentIndex = 0;
      for (int i = 0; i < fileLine.length; i++) {
        final char = fileLine[i];
        final existingList = entries[currentLevel + currentIndex];

        void addItemToCurrentLevel(String char) {
          if (existingList != null) {
            entries[currentLevel + currentIndex]?.add(char);
          } else {
            entries[currentLevel + currentIndex] = [char];
          }
        }

        if ((char == '[' && fileLine.elementAtOrNull(i + 1) == '[') || (char == ']' && fileLine.elementAtOrNull(i + 1) == ']')) {
          continue;
        }
        else if (char == '[' && fileLine.elementAtOrNull(i + 1) == ']') {
          ++currentLevel;
          addItemToCurrentLevel('');
        } else if (char == ',' && fileLine.elementAtOrNull(i - 1) == ']') {
          ++currentIndex;
          if (fileLine.elementAtOrNull(i + 1) != '[') {
            ++currentLevel;
          }
        }
        else if (char == '[') {
          ++currentLevel;
        } else if (char == ']') {
          --currentLevel;
        } else if (char != ',') {
          addItemToCurrentLevel(char);
        }
      }

      return entries;
    }

    return ComparisonPair(getPairFromCurrentString(leftEntries),
        getPairFromCurrentString(rightEntries));
  }

  bool isPairInRightOrder() {

    for (final leftEntry in leftPair.entries) {
      for (int i = 0; i < leftEntry.value.length; i++) {
        final subLeftEntry = leftEntry.value[i];

        final matchingRightEntry = rightPair[leftEntry.key]?.elementAtOrNull(i);

        //Ran out of matching right entires
        if (matchingRightEntry == null || matchingRightEntry.isEmpty) {
          return false;
        }

        //Right side is null
        if (rightPair[leftEntry.key]?.isEmpty == true) {
          return false;
        }

        //Left side ran out of items
        if (subLeftEntry.isEmpty) {
          return true;
        }

        //Left side has value but Right side is empty
        if (subLeftEntry.isNotEmpty && matchingRightEntry.isEmpty) {
          return false;
        }

        //Left entry is smaller
        if (int.parse(subLeftEntry) < int.parse(matchingRightEntry)) {
          return true;
        } else if (int.parse(subLeftEntry) > int.parse(matchingRightEntry)) {
          //Right entry is smaller
          return false;
        }
        //Ran out of matching left entries
        if (i == leftEntry.value.length - 1 && rightPair[leftEntry.key]?.elementAtOrNull(i + 1) != null) {
          return true;
        }
      }
    }

    return false;
  }
}
