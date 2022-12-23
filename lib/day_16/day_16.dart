import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
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
  final List<_Valve> usefulValves = [];

  _TunnelNetwork(this.valves);

  int findOptimalTunnelPath(bool part2) {
    return traverse(
      part2 ? 26 : 30,
      valves['AA']!,
      usefulValves.toSet(),
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

    final distances = computeDistances();

    return currentScore +
        cache.putIfAbsent(currentState, () {
          final maxCurrent = remaining
              .where(
                (next) => distances[current.valveId]![next.valveId]! < minutes,
              )
              .take(1)
              .fold(0, (prev, next) {
            final remainingMinutes =
                minutes - 1 - distances[current.valveId]![next.valveId]!;
            return max(
              prev,
              traverse(
                remainingMinutes,
                next,
                remaining..remove(next),
                cache,
                elephantGoesNext,
              ),
            );
          });
          return max(
            maxCurrent,
            elephantGoesNext
                ? traverse(
                    26,
                    valves['AA']!,
                    usefulValves.toSet(),
                    {},
                    elephantGoesNext,
                  )
                : 0,
          );
        });
  }

  Map<String, Map<String, int>> computeDistances() {
    return Map.fromIterable(
      valves.keys,
      value: (valve) {
        final distances = <String, int>{valve: 0};
        final toVisit = <String>[valve];
        while (toVisit.isNotEmpty) {
          final current = toVisit.removeAt(0);
          valves[current]!.destinations.forEach((neighbour) {
            final newDistance = distances[current]! + 1;
            if (newDistance < (distances[neighbour] ?? 999999999)) {
              distances[neighbour.valveId] = newDistance;
              toVisit.add(neighbour.valveId);
            }
          });
        }
        return distances;
      },
    );
  }

  factory _TunnelNetwork.createFromFileLines(List<String> fileLines) {
    final valves = fileLines.map((e) => _Valve.createFromFileLine(e)).toList();

    for (var i = 0; i < valves.length; i++) {
      valves[i].addDestinations(valves, fileLines[i]);
    }

    return _TunnelNetwork(
      Map.fromIterable(
        valves,
        key: (key) => (key as _Valve).valveId,
        value: (element) => element,
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
      return currentValve.valveId == other.currentValve.valveId &&
          time == other.time &&
          destinations == other.destinations;
    }
    return false;
  }

  @override
  int get hashCode {
    return currentValve.valveId.hashCode ^
        time.hashCode ^
        destinations.hashCode;
  }
}

class _Valve {
  final String valveId;
  final int flowRate;
  final List<_Valve> destinations = [];

  _Valve(this.valveId, this.flowRate);

  factory _Valve.createFromFileLine(String fileLine) {
    return _Valve(
      fileLine.split('Valve ')[1].split(' ')[0],
      int.parse(fileLine.split('flow rate=')[1].split(';')[0]),
    );
  }

  void addDestinations(List<_Valve> valves, String fileLine) {
    final singleTunnel = valves.firstWhereOrNull(
      (element) =>
          fileLine.split('tunnel leads to valve ').elementAtOrNull(1) ==
          element.valveId,
    );
    final multiTunnels = fileLine
        .split('tunnels lead to valves')
        .elementAtOrNull(1)
        ?.split(',')
        .map((e) => e.trim())
        .toList();
    if (singleTunnel != null) {
      destinations.add(singleTunnel);
    } else {
      destinations.addAll(
        valves.where(
          (element) => multiTunnels?.contains(element.valveId) ?? false,
        ),
      );
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is _Valve) {
      return valveId == other.valveId && destinations == other.destinations;
    }
    return false;
  }

  @override
  int get hashCode {
    return valveId.hashCode ^ destinations.hashCode;
  }
}