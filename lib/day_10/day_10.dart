import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day10(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(10);

  final part1 = day10Read(
    fileLines,
  );
  resultReporter.reportResult(10, part1, "SPECIAL OUTPUT");
}

int day10Read(List<String> fileLines) {
  final processor = Processor();

  for (final instruction in fileLines) {
    processor.executeInstruction(instruction);
  }

  processor.crtScreen.drawCurrentScreen();
  return processor.calculateSignalStrength();
}

class Processor {
  int currentValue = 1;
  final List<int> valuesPerCycle = [1];
  final CRTScreen crtScreen = CRTScreen();

  void executeInstruction(String instruction) {
    if (instruction == 'noop') {
      crtScreen.drawSprite(currentValue);
      performCycleOperation();
    } else {
      final split = instruction.split(' ');
      crtScreen
        ..drawSprite(currentValue)
        ..drawSprite(currentValue);
      performCycleOperation();
      currentValue += int.parse(split[1]);
      performCycleOperation();
    }
  }

  void performCycleOperation() {
    valuesPerCycle.add(currentValue);
  }

  int calculateSignalStrength() {
    return valuesPerCycle
        .sublist(19, 220)
        .whereIndexed((index, element) => index % 40 == 0)
        .mapIndexed((index, element) => element * (index * 40 + 20))
        .reduce((a, b) => a + b);
  }
}

class CRTScreen {
  final List<String> pixelGrid = List.generate(6 * 40, (index) => '.');
  int currentPixelIndex = 0;

  void drawSprite(int currentCycleValue) {
    final valuePixelRange = [
      currentCycleValue - 1,
      currentCycleValue,
      currentCycleValue + 1
    ];
    drawPixel(currentPixelIndex,
        valuePixelRange.contains(currentPixelIndex % 40) ? '#' : '.');
    ++currentPixelIndex;
  }

  void drawPixel(index, String char) {
    pixelGrid[index] = char;
  }

  void drawCurrentScreen() {
    for (var i = 0; i < 6; i++) {
      final subList = pixelGrid.sublist(i * 40, (i + 1) * 40);
      print(subList.join());
    }
  }
}
