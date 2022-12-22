import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day5(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(5);
  resultReporter.reportResult(
    5,
    _day5Read(fileLines, false),
    _day5Read(fileLines, true),
  );
}

String _day5Read(List<String> fileLines, bool part2) {
  final craneOperations = <_CraneOperation>[];
  final cargoShip = _CargoShip.createWithContainers(
    (fileLines.first.split('').length - 4) ~/ 3,
  );

  for (final line in fileLines) {
    final charArray = line.split('');
    if (charArray.isNotEmpty) {
      for (var i = 0; i < charArray.length; i++) {
        final currentChar = charArray[i];

        if (currentChar == '[') {
          cargoShip.containers[i ~/ 4].insert(0, charArray[i + 1]);
        }
      }
    }

    if (line.startsWith('move')) {
      final splitLine = line.split(' ');
      final parseAsCraneOperation = _CraneOperation(
        numberOfContainersToMove: int.parse(splitLine[1]),
        sourceContainer: int.parse(splitLine[3]),
        targetContainer: int.parse(splitLine[5]),
      );
      craneOperations.add(parseAsCraneOperation);
      part2
          ? cargoShip.performMultiLiftCraneOperation(parseAsCraneOperation)
          : cargoShip.performCraneOperation(parseAsCraneOperation);
    }
  }

  final topFromEachStack = cargoShip.getTopFromEachStack();
  return topFromEachStack;
}

class _CargoShip {
  final List<List<String>> containers;

  _CargoShip(this.containers);

  void performCraneOperation(_CraneOperation craneOperation) {
    for (var i = 0; i < craneOperation.numberOfContainersToMove; i++) {
      containers[craneOperation.targetContainer - 1]
          .add(containers[craneOperation.sourceContainer - 1].removeLast());
    }
  }

  void performMultiLiftCraneOperation(_CraneOperation craneOperation) {
    final sourceContainerLength =
        containers[craneOperation.sourceContainer - 1].length;
    final allItemsToMove = containers[craneOperation.sourceContainer - 1]
        .reversed
        .take(craneOperation.numberOfContainersToMove)
        .toList()
        .reversed;
    containers[craneOperation.targetContainer - 1].addAll(allItemsToMove);
    containers[craneOperation.sourceContainer - 1].removeRange(
        sourceContainerLength - craneOperation.numberOfContainersToMove,
        sourceContainerLength);
  }

  String getTopFromEachStack() {
    return containers.map((e) => e.last).join();
  }

  factory _CargoShip.createWithContainers(int amountOfContainers) {
    return _CargoShip(List.generate(amountOfContainers, (index) => []));
  }
}

class _CraneOperation {
  final int sourceContainer;
  final int numberOfContainersToMove;
  final int targetContainer;

  _CraneOperation(
      {required this.numberOfContainersToMove,
      required this.sourceContainer,
      required this.targetContainer});
}
