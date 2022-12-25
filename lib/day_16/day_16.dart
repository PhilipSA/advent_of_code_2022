import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/path_finding.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day16(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(16);

  final part1 = _day16Read(fileLines, false);
  final part2 = _day16Read(fileLines, true);

  resultReporter.reportResult(16, part1, part2);
}

int _day16Read(List<String> fileLines, bool part2) {
  final tunnelNetwork = _TunnelNetwork.createFromFileLines(fileLines);

  return tunnelNetwork.findOptimalTunnelPath(part2);
}

class _TunnelNetwork {
  final Map<String, _Valve> valves;
  final Set<_Valve> usefulValves = Set();
  final Map<String, Map<String, int>> distances;

  _TunnelNetwork(this.valves, this.distances);

  int findOptimalTunnelPath(bool part2) {
    usefulValves.addAll(valves.values.where((element) => element.flowRate > 0));

    return traverse(
      part2 ? 26 : 30,
      valves['AA']!,
      usefulValves,
      {},
      part2,
    );
  }

  int traverse(
    int minutes,
    _Valve current,
    Set<_Valve> remaining,
    Map<_State, int> cache,
    bool elephantGoesNext,
  ) {
    final currentScore = minutes * current.flowRate;
    final currentState = _State(current, remaining, minutes);

    int traverseRemaining(int minutes) {
      final remainingInRange = remaining.where((e) => minutes > distances[current.objectId]![e.objectId]!);

      return remainingInRange.map(
            (e) => traverse(
          minutes - distances[current.objectId]![e.objectId]!,
          e,
          remaining.whereNot((element) => e == element).toSet(),
          cache,
          elephantGoesNext,
        ),
      )
          .sorted((a, b) => a.compareTo(b))
          .lastOrNull ??
          0;
    }

    final openedThisValue = traverseRemaining(minutes - 1);

    cache[currentState] = max(
      openedThisValue,
      elephantGoesNext
          ? traverse(26, valves['AA']!, remaining, cache, false)
          : 0,
    );

    return currentScore + cache[currentState]!;
  }

  factory _TunnelNetwork.createFromFileLines(List<String> fileLines) {
    final valves = fileLines.map((e) => _Valve.createFromFileLine(e)).toList();

    return _TunnelNetwork(
      Map.fromIterable(
        valves,
        key: (key) => (key as _Valve).objectId,
        value: (element) => element,
      ),
      Map.fromIterable(
        valves,
        key: (key) => (key as _Valve).objectId,
        value: (valve) => BreadthFirstSearch(valve, valves.toSet())
            .map((key, value) => MapEntry(key.objectId, value)),
      ),
    );
  }
}

class _State {
  final _Valve currentValve;
  final Set<_Valve> destinations;
  final int time;

  _State(this.currentValve, this.destinations, this.time);

  @override
  bool operator ==(Object other) {
    if (other is _State) {
      return currentValve.objectId == other.currentValve.objectId &&
          time == other.time &&
          destinations.every((element) => other.destinations.contains(element));
    }
    return false;
  }

  @override
  int get hashCode {
    var result = currentValve.objectId.hashCode ^ time.hashCode;
    for (final element in destinations) {
      result = 31 * result + element.hashCode;
    }
    return result;
  }
}

class _Valve extends BFSObject {
  final int flowRate;

  _Valve(super.objectId, super.neighbors, this.flowRate);

  factory _Valve.createFromFileLine(String fileLine) {
    List<String> addDestinations(String fileLine) {
      final singleTunnel =
          fileLine.split('tunnel leads to valve ').elementAtOrNull(1);
      final multiTunnels = fileLine
          .split('tunnels lead to valves')
          .elementAtOrNull(1)
          ?.split(',')
          .map((e) => e.trim())
          .toList();

      return singleTunnel != null ? [singleTunnel] : multiTunnels!;
    }

    return _Valve(
      fileLine.split('Valve ')[1].split(' ')[0],
      addDestinations(fileLine),
      int.parse(fileLine.split('flow rate=')[1].split(';')[0]),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is _Valve) {
      return objectId == other.objectId;
    }
    return false;
  }

  @override
  int get hashCode {
    return objectId.hashCode;
  }
}
