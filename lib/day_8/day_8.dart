import 'dart:collection';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day8(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(8);

  final part1 = _day8Read(fileLines).getVisibleTrees().length;
  final part2 = _day8Read(fileLines).getHighestTreeScenicScore();

  resultReporter.reportResult(8, part1, part2);
}

_Forest _day8Read(List<String> fileLines) {
  final forest =
      _Forest.generate(fileLines.length, fileLines.first.split('').length);

  for (var y = 0; y < fileLines.length; y++) {
    final allTreesOnLine = fileLines[y].split('');
    for (var x = 0; x < allTreesOnLine.length; x++) {
      final treeHeight = int.parse(allTreesOnLine[x]);
      forest.addTree(treeHeight, x, y);
    }
  }

  return forest;
}

class _Forest {
  final List<List<_Tree?>> treeGrid;
  final int gridHeight;
  final int gridWidth;

  _Forest(this.gridHeight, this.gridWidth, this.treeGrid);

  factory _Forest.generate(int gridHeight, int gridWidth) {
    return _Forest(
      gridHeight,
      gridWidth,
      List.generate(
        gridHeight,
        (index) => List.generate(gridWidth, (index) => null),
      ),
    );
  }

  void addTree(int height, int x, int y) {
    treeGrid[x][y] = _Tree(height, x, y);
  }

  void iterateGrid(
    Function(
      _Tree currentTree,
      int currentRowLength,
      int currentColumnLength,
      List<_Tree?> treesToTheLeft,
      List<_Tree?> treesToTheRight,
      List<_Tree?> treesToTheTop,
      List<_Tree?> treesToTheBottom,
    )
        gridCalculation,
  ) {
    for (var y = 0; y < treeGrid.length; y++) {
      for (var x = 0; x < treeGrid.first.length; x++) {
        final currentTree = treeGrid[x][y]!;

        final currentRow = treeGrid.map((row) => row[y]).toList();

        final currentColumn = <_Tree>[];
        for (var z = 0; z < treeGrid.length; z++) {
          currentColumn.add(treeGrid[x][z]!);
        }

        final treesToTheLeft = currentRow.sublist(0, currentTree.x);
        final treesToTheRight =
            currentRow.sublist(currentTree.x + 1, currentRow.length);
        final treesToTheTop = currentColumn.sublist(0, currentTree.y);
        final treesToTheBottom =
            currentColumn.sublist(currentTree.y + 1, currentColumn.length);

        gridCalculation(
          currentTree,
          currentRow.length,
          currentColumn.length,
          treesToTheLeft,
          treesToTheRight,
          treesToTheTop,
          treesToTheBottom,
        )();
      }
    }
  }

  int getHighestTreeScenicScore() {
    var currentHighScore = 0;

    iterateGrid(
      (
        currentTree,
        currentRowLength,
        currentColumnLength,
        treesToTheLeft,
        treesToTheRight,
        treesToTheTop,
        treesToTheBottom,
      ) =>
          () {
        final scenicScoreLeft = currentTree.x -
            (treesToTheLeft
                    .lastWhereOrNull(
                      (element) => (element?.height ?? 0) >= currentTree.height,
                    )
                    ?.x ??
                0);
        final scenicScoreRight = (treesToTheRight
                    .firstWhereOrNull(
                      (element) => (element?.height ?? 0) >= currentTree.height,
                    )
                    ?.x ??
                currentRowLength - 1) -
            currentTree.x;
        final scenicScoreTop = currentTree.y -
            (treesToTheTop
                    .lastWhereOrNull(
                      (element) => element!.height >= currentTree.height,
                    )
                    ?.y ??
                0);
        final scenicScoreBottom = (treesToTheBottom
                    .firstWhereOrNull(
                      (element) => element!.height >= currentTree.height,
                    )
                    ?.y ??
                currentColumnLength - 1) -
            currentTree.y;

        final totalScore = scenicScoreLeft *
            scenicScoreRight *
            scenicScoreTop *
            scenicScoreBottom;
        if (totalScore > currentHighScore) {
          currentHighScore = totalScore;
        }

        return currentHighScore;
      },
    );

    return currentHighScore;
  }

  HashSet<_Tree> getVisibleTrees() {
    final visibleTrees = HashSet<_Tree>();

    iterateGrid(
      (
        currentTree,
        currentRowLength,
        currentColumnLength,
        treesToTheLeft,
        treesToTheRight,
        treesToTheTop,
        treesToTheBottom,
      ) =>
          () {
        if (treesToTheLeft
                .every((element) => element!.height < currentTree.height) ||
            treesToTheRight
                .every((element) => element!.height < currentTree.height) ||
            treesToTheTop
                .every((element) => element!.height < currentTree.height) ||
            treesToTheBottom
                .every((element) => element!.height < currentTree.height)) {
          visibleTrees.add(currentTree);
        }
      },
    );

    return visibleTrees;
  }
}

class _Tree {
  final int height;
  final int x;
  final int y;

  _Tree(this.height, this.x, this.y);
}
