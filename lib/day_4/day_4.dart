import 'dart:ffi';
import 'dart:io';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/math.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day4(IResultReporter resultReporter) {
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

  resultReporter.reportResult(4, sum, overlapsSum);
}
