import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day11(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(11);

  final part1 = _day11Read(fileLines, 20, true);
  final part2 = _day11Read(fileLines, 10000, false);

  resultReporter.reportResult(11, part1, part2);
}

int _day11Read(
  List<String> fileLines,
  int numberOfRounds,
  bool reduceWorryLevel,
) {
  final roundTracker = _RoundTracker(reduceWorryLevel);

  for (var i = 0; i < fileLines.length; i++) {
    final line = fileLines[i];
    if (line.startsWith('Monkey')) {
      roundTracker.silverBacks
          .add(_Max.createFromFileLine(fileLines.sublist(i + 1, i + 6)));
    }
  }

  roundTracker.monkeyBusiness(numberOfRounds);

  return roundTracker.silverBacks
      .sorted(
        (a, b) =>
            b.numberOfItemInspections.compareTo(a.numberOfItemInspections),
      )
      .take(2)
      .map((e) => e.numberOfItemInspections)
      .reduce((value, element) => value * element);
}

class _RoundTracker {
  final List<_Max> silverBacks = [];
  final bool reduceWorryLevel;

  int get modBy => silverBacks
      .map((e) => e.divisibleBy)
      .reduce((value, element) => value * element);

  _RoundTracker(this.reduceWorryLevel);

  void monkeyBusiness(int numberOfRounds) {
    for (var i = 0; i < numberOfRounds; i++) {
      for (final silverBack in silverBacks) {
        final itemsToThrow = <_ThrowAction>[];

        for (final item in silverBack.heldItems) {
          itemsToThrow.add(
            _ThrowAction(
              item,
              silverBack.getIndexForMonkeyToThrowTo(
                item,
                modBy,
                reduceWorryLevel,
              ),
            ),
          );
        }

        for (final throwAction in itemsToThrow) {
          silverBack.heldItems.remove(throwAction.item);
          silverBacks[throwAction.targetSilverBackIndex]
              .heldItems
              .add(throwAction.item);
        }
      }
    }
  }
}

class _Max {
  final List<_Item> heldItems;
  final _Operation operation;
  final int divisibleBy;
  final int trueMaxIndex;
  final int falseMaxIndex;
  var numberOfItemInspections = 0;

  _Max(
    this.heldItems,
    this.operation,
    this.divisibleBy,
    this.trueMaxIndex,
    this.falseMaxIndex,
  );

  factory _Max.createFromFileLine(List<String> monkeyLines) {
    return _Max(
      monkeyLines[0]
          .split('Starting items:')[1]
          .split(',')
          .map(
            (e) => _Item(int.parse(e)),
          )
          .toList(),
      _Operation(monkeyLines[1].split('Operation: new =')[1].trim()),
      int.parse(monkeyLines[2].split('Test: divisible by')[1]),
      int.parse(monkeyLines[3].split('If true: throw to monkey')[1]),
      int.parse(monkeyLines[4].split('If false: throw to monkey')[1]),
    );
  }

  int getIndexForMonkeyToThrowTo(_Item item, int modBy, bool reduceWorryLevel) {
    final boredWorryLevel = inspectItem(item, modBy, reduceWorryLevel);

    if (boredWorryLevel % divisibleBy == 0) {
      return trueMaxIndex;
    } else {
      return falseMaxIndex;
    }
  }

  int inspectItem(_Item item, int modBy, bool reduceWorryLevel) {
    ++numberOfItemInspections;

    final newItemWorryLevel = operation.getNewWorryLevel(item);

    final boredWorryLevel =
        reduceWorryLevel ? newItemWorryLevel ~/ 3 : newItemWorryLevel % modBy;

    item.itemWorryLevel = boredWorryLevel;

    return boredWorryLevel;
  }
}

class _Operation {
  final String operation;

  _Operation(this.operation);

  int getNewWorryLevel(_Item item) {
    final operationSign = operation.split(' ')[1];
    final rightHandOperation = operation.split(' ')[2];
    final rightHandOperationValue = rightHandOperation == 'old'
        ? item.itemWorryLevel
        : int.parse(rightHandOperation);

    if (operationSign == '+') {
      return item.itemWorryLevel + rightHandOperationValue;
    } else if (operationSign == '*') {
      return item.itemWorryLevel.toUnsigned(64) *
          rightHandOperationValue.toUnsigned(64);
    }

    return 0;
  }
}

class _ThrowAction {
  _Item item;
  int targetSilverBackIndex;

  _ThrowAction(this.item, this.targetSilverBackIndex);
}

class _Item {
  int itemWorryLevel;

  _Item(this.itemWorryLevel);
}
