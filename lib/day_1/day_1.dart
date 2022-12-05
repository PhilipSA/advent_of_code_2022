import 'package:advent_of_code_2002/util/file_util.dart';

int day1() {
  final inputFileLines = getInputFileLines(1);

  final Map<int, int> elvesMap = {};
  var currentElf = 1;

  for (final line in inputFileLines) {
    if (line.isNotEmpty) {
      final currentElfValue = elvesMap[currentElf] ?? 0;
      elvesMap[currentElf] = currentElfValue + int.parse(line);
    } else {
      currentElf += 1;
    }
  }

  final answerEntry = elvesMap.entries.reduce((value, element) => value.value > element.value ? value : element);
  final bonusAnswer = day1Bonus(elvesMap);

  return answerEntry.value;
}

int day1Bonus(Map<int, int> elvesMap) {
  final elvesMapList = elvesMap.entries.toList();
  elvesMapList.sort((a, b) => b.value.compareTo(a.value));
  final sorted = elvesMapList.take(3);
  return sorted.map((e) => e.value).reduce((a, b) => a + b);
}