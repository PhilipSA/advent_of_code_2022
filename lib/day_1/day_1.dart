import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day1(IResultReporter resultReporter) {
  final inputFileLines = getInputFileLines(1);

  final elvesMap = <int, int>{};
  var currentElf = 1;

  for (final line in inputFileLines) {
    if (line.isNotEmpty) {
      final currentElfValue = elvesMap[currentElf] ?? 0;
      elvesMap[currentElf] = currentElfValue + int.parse(line);
    } else {
      currentElf += 1;
    }
  }

  final answerEntry = elvesMap.entries.reduce(
    (value, element) => value.value > element.value ? value : element,
  );
  final bonusAnswer = day1Bonus(elvesMap);

  resultReporter.reportResult(1, answerEntry.value, bonusAnswer);
}

int day1Bonus(Map<int, int> elvesMap) {
  final elvesMapList = elvesMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final sorted = elvesMapList.take(3);
  return sorted.map((e) => e.value).reduce((a, b) => a + b);
}
