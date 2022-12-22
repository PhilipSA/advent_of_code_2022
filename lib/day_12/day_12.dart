import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/path_finding.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day12(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(12);

  final part1 = _day12Read(fileLines, false);
  final part2 = _day12Read(fileLines, true);

  resultReporter.reportResult(12, part1, part2);
}

int _day12Read(List<String> fileLines, bool part2) {
  final pathFinder = _PathFinder.createFromFileLines(fileLines);
  final takenPath = aStar(pathFinder.startNode, pathFinder.goalNode);

  if (part2) {
    var shortestPath = 100000000000;
    for (final startNode in pathFinder.alternativeStartNodes) {
      for (final node in pathFinder.heightMap) {
        node
          ..searchValue = 0
          ..costSoFar = 0
          ..cameFrom = null;
      }

      final pathLength = aStar(startNode, pathFinder.goalNode);
      if (pathLength.length < shortestPath && pathLength.isNotEmpty) {
        shortestPath = pathLength.length - 1;
      }
    }
    return shortestPath - 1;
  }

  return takenPath.length - 1;
}

class _PathFinder {
  final List<SearchNode> heightMap;
  final SearchNode startNode;
  final SearchNode goalNode;

  List<SearchNode> get alternativeStartNodes => heightMap
      .where((element) =>
          element.height == 'a'.codeUnits[0] &&
          element.neighbors
              .any((element) => element.height != 'a'.codeUnits[0]))
      .toList();

  _PathFinder(this.heightMap, this.startNode, this.goalNode);

  factory _PathFinder.createFromFileLines(List<String> fileLines) {
    final heightMap = <SearchNode>[];
    late SearchNode startNode;
    late SearchNode goalNode;

    for (var y = 0; y < fileLines.length; y++) {
      final lineSplit = fileLines[y].split('');

      for (var x = 0; x < lineSplit.length; x++) {
        final char = lineSplit[x];

        if (char == 'S') {
          final newStartNode = SearchNode('a'.codeUnits[0], x, y);
          heightMap.add(newStartNode);
          startNode = newStartNode;
        } else if (char == 'E') {
          goalNode = SearchNode('z'.codeUnits[0], x, y);
          heightMap.add(goalNode);
        } else {
          heightMap.add(SearchNode(char.codeUnits[0], x, y));
        }
      }
    }

    for (final node in heightMap) {
      final allNeighbors = heightMap.where((element) =>
          element.isNeighbor(node) &&
          ((node.height - element.height).abs() <= 1 ||
              node.height > element.height));
      node.neighbors.addAll(allNeighbors);
    }

    return _PathFinder(heightMap, startNode, goalNode);
  }
}
