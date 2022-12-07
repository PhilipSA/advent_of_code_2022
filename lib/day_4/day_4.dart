import 'dart:ffi';
import 'dart:io';

import 'package:advent_of_code_2022/util/file_util.dart';

class IntRange {
  final int lowest;
  final int highest;

  IntRange(this.lowest, this.highest);
  
  bool isWithinRange(IntRange otherRange) {
    return (lowest <= otherRange.lowest && highest >= otherRange.highest) || (otherRange.lowest <= lowest && otherRange.highest >= highest);
  }

  bool doesRangeOverlap(IntRange otherRange) {
    return (highest >= otherRange.lowest && lowest <= otherRange.highest) || (lowest >= otherRange.highest && highest <= otherRange.highest);
  }

  factory IntRange.createFromRangeString(String input) {
    final split = input.split('-');
    return IntRange(int.parse(split[0]), int.parse(split[1]));
  }
}

int day4() {
  final fileLines = getInputFileLines(4);

  var sum = 0;
  var overlapsSum = 0;

  for (final line in fileLines) {
    final splitLine = line.split(',');
    final firstRange = IntRange.createFromRangeString(splitLine[0]);
    final secondRange = IntRange.createFromRangeString(splitLine[1]);

    if (firstRange.isWithinRange(secondRange)) {
      ++sum;
    }
    if (firstRange.doesRangeOverlap(secondRange)) {
      ++overlapsSum;
    }
  }

  return sum;
}
