import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day20(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(20);

  final part1 = _day20Read(fileLines, false);
  final part2 = 2; //_day20Read(fileLines, true);

  resultReporter.reportResult(20, part1, part2);
}

int _day20Read(List<String> fileLines, bool part2) {
  var numbers = fileLines
      .mapIndexed((index, e) => _NumberWrapper(index, int.parse(e)))
      .toList();
  final numbersCopy = numbers.toList();

  for (final number in numbersCopy) {
    final numbersReversed =
        number.number < 0 ? numbers.reversed.toList() : numbers;
    final index = numbersReversed
        .indexWhere((element) => element.originalIndex == number.originalIndex);
    final newIndex = index + number.number.abs();

    numbersReversed
      ..removeAt(index)
      ..insert(newIndex % (numbersCopy.length - 1), number);

    if (number.number < 0) {
      numbers = numbersReversed.reversed.toList();
    }
  }

  final number0Index = numbers.indexWhere((element) => element.number == 0);

  return numbers.elementAt((number0Index + 1000) % (numbersCopy.length - 1)).number +
      numbers.elementAt((number0Index + 2000) % (numbersCopy.length - 1)).number +
      numbers.elementAt((number0Index + 3000) % (numbersCopy.length - 1)).number;
}

class _NumberWrapper {
  final int originalIndex;
  final int number;

  _NumberWrapper(this.originalIndex, this.number);
}
