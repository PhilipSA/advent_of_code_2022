import 'dart:io';

List<String> getInputFileLines(int day) {
  return File('lib/day_$day/day_${day}_input.txt')
      .readAsLinesSync();
}