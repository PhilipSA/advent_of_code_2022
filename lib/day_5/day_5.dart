import 'package:advent_of_code_2002/util/file_util.dart';

class CargoShip {
  final List<List<String>> containers;

  CargoShip(this.containers);

  void performCraneOperation(CraneOperation craneOperation) {
    for (int i = 0; i < craneOperation.numberOfContainersToMove; i++) {
      containers[craneOperation.targetContainer - 1]
          .add(containers[craneOperation.sourceContainer - 1].removeLast());
    }
  }

  void performMultiLiftCraneOperation(CraneOperation craneOperation) {
    final sourceContainerLength = containers[craneOperation.sourceContainer - 1].length;
    final allItemsToMove = containers[craneOperation.sourceContainer - 1].reversed.take(craneOperation.numberOfContainersToMove).toList().reversed;
    containers[craneOperation.targetContainer - 1].addAll(allItemsToMove);
    containers[craneOperation.sourceContainer - 1].removeRange(sourceContainerLength - craneOperation.numberOfContainersToMove, sourceContainerLength);
  }

  String getTopFromEachStack() {
    return containers.map((e) => e.last).join();
  }

  factory CargoShip.createWithContainers(int amountOfContainers) {
    return CargoShip(List.generate(amountOfContainers, (index) => []));
  }
}

class CraneOperation {
  final int sourceContainer;
  final int numberOfContainersToMove;
  final int targetContainer;

  CraneOperation(
      {required this.numberOfContainersToMove,
      required this.sourceContainer,
      required this.targetContainer});
}

String day5() {
  final fileLines = getInputFileLines(5);

  final List<CraneOperation> craneOperations = [];
  final cargoShip = CargoShip.createWithContainers(
      (fileLines.first.split('').length - 4) ~/ 3);

  for (final line in fileLines) {
    final charArray = line.split('');
    if (charArray.isNotEmpty) {
      for (int i = 0; i < charArray.length; i++) {
        final currentChar = charArray[i];

        if (currentChar == '[') {
          cargoShip.containers[i ~/ 4].insert(0, charArray[i + 1]);
        }
      }
    }

    if (line.startsWith('move')) {
      final splitLine = line.split(' ');
      final parseAsCraneOperation = CraneOperation(
        numberOfContainersToMove: int.parse(splitLine[1]),
        sourceContainer: int.parse(splitLine[3]),
        targetContainer: int.parse(splitLine[5]),
      );
      craneOperations.add(parseAsCraneOperation);
      cargoShip.performMultiLiftCraneOperation(parseAsCraneOperation);
    }
  }

  final topFromEachStack = cargoShip.getTopFromEachStack();
  return topFromEachStack;
}
