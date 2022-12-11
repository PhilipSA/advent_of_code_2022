import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day11() {
  final fileLines = getInputFileLines(11);

  final part1 = day11Read(fileLines, 20, true);
  final part2 = day11Read(fileLines, 10000, false);
  print("Day 11 part 1: $part1 part 2: $part2");
}

int day11Read(
    List<String> fileLines, int numberOfRounds, bool reduceWorryLevel) {
  final roundTracker = RoundTracker(reduceWorryLevel);

  for (int i = 0; i < fileLines.length; i++) {
    final line = fileLines[i];
    if (line.startsWith('Monkey')) {
      roundTracker.silverBacks
          .add(Max.createFromFileLine(fileLines.sublist(i + 1, i + 6)));
    }
  }

  roundTracker.monkeyBusiness(numberOfRounds);

  return roundTracker.silverBacks
      .sorted((a, b) =>
          b.numberOfItemInspections.compareTo(a.numberOfItemInspections))
      .take(2)
      .map((e) => e.numberOfItemInspections)
      .reduce((value, element) => value * element);
}

class RoundTracker {
  final List<Max> silverBacks = [];
  final bool reduceWorryLevel;
  int get modBy => silverBacks.map((e) => e.divisibleBy).reduce((value, element) => value * element);

  RoundTracker(this.reduceWorryLevel);

  void monkeyBusiness(int numberOfRounds) {
    for (int i = 0; i < numberOfRounds; i++) {
      for (final silverBack in silverBacks) {
        final List<ThrowAction> itemsToThrow = [];

        for (final item in silverBack.heldItems) {
          itemsToThrow.add(ThrowAction(item,
              silverBack.getIndexForMonkeyToThrowTo(item, modBy, reduceWorryLevel)));
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

class Max {
  final List<Item> heldItems;
  final Operation operation;
  final int divisibleBy;
  final int trueMaxIndex;
  final int falseMaxIndex;
  var numberOfItemInspections = 0;

  Max(this.heldItems, this.operation, this.divisibleBy, this.trueMaxIndex,
      this.falseMaxIndex);

  factory Max.createFromFileLine(List<String> monkeyLines) {
    return Max(
        monkeyLines[0]
            .split('Starting items:')[1]
            .split(',')
            .map(
              (e) => Item(int.parse(e)),
            )
            .toList(),
        Operation(monkeyLines[1].split('Operation: new =')[1].trim()),
        int.parse(monkeyLines[2].split('Test: divisible by')[1]),
        int.parse(monkeyLines[3].split('If true: throw to monkey')[1]),
        int.parse(monkeyLines[4].split('If false: throw to monkey')[1]));
  }

  int getIndexForMonkeyToThrowTo(Item item, int modBy, bool reduceWorryLevel) {
    final boredWorryLevel = inspectItem(item, modBy, reduceWorryLevel);

    if (boredWorryLevel % divisibleBy == 0) {
      return trueMaxIndex;
    } else {
      return falseMaxIndex;
    }
  }

  int inspectItem(Item item, int modBy, bool reduceWorryLevel) {
    ++numberOfItemInspections;

    final newItemWorryLevel = operation.getNewWorryLevel(item);

    final boredWorryLevel =
        reduceWorryLevel ? newItemWorryLevel ~/ 3 : newItemWorryLevel % modBy;

    item.itemWorryLevel = boredWorryLevel;

    return boredWorryLevel;
  }
}

class Operation {
  final String operation;

  Operation(this.operation);

  int getNewWorryLevel(Item item) {
    final operationSign = operation.split(' ')[1];
    final rightHandOperation = operation.split(' ')[2];
    final rightHandOperationValue = rightHandOperation == 'old'
        ? item.itemWorryLevel
        : int.parse(rightHandOperation);

    if (operationSign == '+') {
      return item.itemWorryLevel + rightHandOperationValue;
    } else if (operationSign == '*') {
      return item.itemWorryLevel.toUnsigned(64) * rightHandOperationValue.toUnsigned(64);
    }


    throw ('Incorrent operation performed');
  }
}

class ThrowAction {
  Item item;
  int targetSilverBackIndex;

  ThrowAction(this.item, this.targetSilverBackIndex);
}

class Item {
  int itemWorryLevel;

  Item(this.itemWorryLevel);
}
