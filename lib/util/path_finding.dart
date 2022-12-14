import 'dart:collection';

import 'package:advent_of_code_2022/util/geometry.dart';

class SearchNode extends TwoDObject {
  final int height;
  final List<SearchNode> neighbors = [];
  SearchNode? cameFrom;
  double costSoFar = 0;
  double searchValue = 0;

  SearchNode(this.height, super.x, super.y);
}


List<SearchNode> aStar(SearchNode startNode, SearchNode goalNode) {
  final path = <SearchNode>[];
  final frontier = HashSet<SearchNode>()..add(startNode);
  final explored = HashSet<SearchNode>();

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

      nextNode
        ..cameFrom = node
        ..costSoFar = costSoFar
        ..searchValue = nextNode.costSoFar + nextNode.heuristic(goalNode);
    }
  }

  return path.toList();
}

abstract class BFSObject {
  final String objectId;
  final List<String> neighbors;
  BFSObject(this.objectId, this.neighbors);
}

Map<BFSObject, int> BreadthFirstSearch(BFSObject start, Set<BFSObject> searchSpace) {
  final distances = Map<BFSObject, int>();
  final queue = Queue<BFSObject>();
  final visited = Set<BFSObject>();
  queue.add(start);
  distances[start] = 0;

  while (queue.isNotEmpty) {
    final current = queue.removeFirst();
    visited.add(current);

    for (final neighbor in searchSpace.where((element) => current.neighbors.contains(element.objectId))) {
      if (!visited.contains(neighbor)) {
        // Set the distance to the neighbor to the distance to the current object + 1
        distances[neighbor] = distances[current]! + 1;
        queue.add(neighbor);
      }
    }
  }
  return distances;
}