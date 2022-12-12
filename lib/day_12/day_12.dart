import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';

void day12() {
  final fileLines = getInputFileLines(12);

  final part1 = day12Read(fileLines, false);
  final part2 = day12Read(fileLines, true);
  print("Day 12 part 1: $part1 part 2: $part2");
}

int day12Read(List<String> fileLines, bool part2) {
  final pathFinder = PathFinder.createFromFileLines(fileLines);
  final takenPath = pathFinder.aStar(pathFinder.startNode);

  if (part2) {
    var shortestPath = 100000000000;
    for (final startNode in pathFinder.alternativeStartNodes) {
      final pathFinderCopy = PathFinder.createFromFileLines(fileLines);
      final startNodeInCopy = pathFinderCopy.alternativeStartNodes.firstWhere(
          (element) => element.x == startNode.x && element.y == startNode.y);
      final pathLength = pathFinderCopy.aStar(startNodeInCopy);
      if (pathLength.length < shortestPath && pathLength.isNotEmpty) {
        shortestPath = pathLength.length - 1;
      }
    }
    return shortestPath - 1;
  }

  return takenPath.length - 1;
}

class PathFinder {
  final List<Node> heightMap;
  final Node startNode;
  final Node goalNode;

  List<Node> get alternativeStartNodes => heightMap
      .where((element) =>
          element.height == 'a'.codeUnits[0] &&
          element.neighbors
              .any((element) => element.height != 'a'.codeUnits[0]))
      .toList();

  PathFinder(this.heightMap, this.startNode,
      this.goalNode);

  factory PathFinder.createFromFileLines(List<String> fileLines) {
    List<Node> heightMap = [];
    late Node startNode;
    late Node goalNode;

    for (int y = 0; y < fileLines.length; y++) {
      final lineSplit = fileLines[y].split('');

      for (int x = 0; x < lineSplit.length; x++) {
        final char = lineSplit[x];

        if (char == 'S') {
          final newStartNode = Node('a'.codeUnits[0], x, y);
          heightMap.add(newStartNode);
          startNode = newStartNode;
        } else if (char == 'E') {
          goalNode = Node('z'.codeUnits[0], x, y);
          heightMap.add(goalNode);
        } else {
          heightMap.add(Node(char.codeUnits[0], x, y));
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

    return PathFinder(heightMap, startNode, goalNode);
  }

  List<Node> aStar(Node startNode) {
    final path = <Node>[];
    final frontier = HashSet<Node>()..add(startNode);
    final explored = HashSet<Node>();

    while (frontier.isNotEmpty) {
      final node = frontier.reduce((current, next) =>
          current.searchValue < next.searchValue ? current : next);
      frontier.remove(node);
      if (node == goalNode) {
        var backTrack = node;
        while (backTrack != startNode) {
          path.add(backTrack);
          backTrack = backTrack.cameFrom!;
        }
        path.add(startNode);
        return path.toList().reversed.toList();
      }
      explored.add(node);
      for (final nextNode in node.neighbors) {
        final costSoFar = node.costSoFar + node.heuristic(nextNode);

        if (explored.contains(nextNode)) {
          continue;
        }

        if (!frontier.add(nextNode) && costSoFar >= nextNode.costSoFar) {
          continue;
        }

        nextNode.cameFrom = node;
        nextNode.costSoFar = costSoFar;
        nextNode.searchValue =
            nextNode.costSoFar + nextNode.heuristic(goalNode);
      }
    }

    return path.toList();
  }
}

class SearchNode {
  SearchNode? cameFrom;
  double costSoFar = 0;
  double searchValue = 0;
  Node node;
  final List<SearchNode> neighbors;

  SearchNode(this.node, this.neighbors);

  double heuristic(SearchNode otherNode) {
    final newX = (node.x - otherNode.node.x).abs();
    final newY = (node.y - otherNode.node.y).abs();
    return sqrt(newX * newX + newY * newY);
  }
}

class Node {
  final int height;
  final int x;
  final int y;
  final List<Node> neighbors = [];
  Node? cameFrom;
  double costSoFar = 0;
  double searchValue = 0;

  Node(this.height, this.x, this.y);

  bool isNeighbor(Node otherNode) {
    return (otherNode.x == x - 1 && otherNode.y == y) ||
        (otherNode.x == x + 1 && otherNode.y == y) ||
        (otherNode.x == x && otherNode.y == y + 1) ||
        (otherNode.x == x && otherNode.y == y - 1);
  }

  double heuristic(Node otherNode) {
    final newX = (x - otherNode.x).abs();
    final newY = (y - otherNode.y).abs();
    return sqrt(newX * newX + newY * newY);
  }
}