import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:collection/collection.dart';

void day16() {
  final fileLines = getInputFileLines(16);

  final part1 = day16Read(fileLines, false);
  final part2 = 2; //day16Read(fileLines, true);
  print('Day 16 part 1: $part1 part 2: $part2');
}

int day16Read(List<String> fileLines, bool part2) {
  final tunnelNetwork = TunnelNetwork.createFromFileLines(fileLines);

  return tunnelNetwork.findOptimalTunnelPath();
}

class TunnelNetwork {
  final List<Valve> valves;
  int timeLimit = 30;
  int currentPressure = 0;

  TunnelNetwork(this.valves);

  int findOptimalTunnelPath() {
    final targetPressure = valves
        .map((e) => e.flowRate)
        .reduce((value, element) => value + element);
    var currentValve = valves.first;

    while (currentPressure < targetPressure && timeLimit > 0) {
      final sortValvesByRank = [...currentValve.destinations, currentValve]
          .sorted(
            (a, b) => getOptimalValveRanking(b, timeLimit).compareTo(getOptimalValveRanking(a, timeLimit)),
      );
      final betterValveInDestination = sortValvesByRank.first;

      if (betterValveInDestination != currentValve) {
        currentValve = betterValveInDestination;
        print('$timeLimit walked to ${betterValveInDestination.valveId}');
      } else {
        if (!currentValve.isOpen) {
          currentValve.isOpen = true;
          currentPressure += currentValve.flowRate;
          print('$timeLimit opened valve ${currentValve.valveId}');
        } else {
          print('$timeLimit staying at ${currentValve.valveId}');
        }
      }
      timeLimit -= 1;
    }

    return currentPressure;
  }

  int getOptimalValveRanking(Valve valve, int timeLeft) {
    var currentRank = valve.valveRanking - (30 - timeLeft);

    final destinations = HashSet<Valve>()..addAll(valve.destinations);
    final visitedDestinations = HashSet<Valve>();

    while (destinations.isNotEmpty) {
      final destination = destinations.toList().removeLast();
      visitedDestinations.add(destination);
      destinations.addAll(destination.destinations.whereNot((element) => visitedDestinations.contains(element)));
      --timeLeft;

      if (timeLeft <= 0) {
        break;
      }

      currentRank += destination.valveRanking - (30 - timeLeft);
    }

    return currentRank;
  }

  factory TunnelNetwork.createFromFileLines(List<String> fileLines) {
    final valves = fileLines.map((e) => Valve.createFromFileLine(e)).toList();

    for (var i = 0; i < valves.length; i++) {
      valves[i].addDestinations(valves, fileLines[i]);
    }

    return TunnelNetwork(
      valves,
    );
  }
}

class Valve {
  final String valveId;
  final int flowRate;
  final List<Valve> destinations = [];
  bool isOpen = false;

  int get valveRanking => isOpen ? 0 : flowRate;

  Valve(this.valveId, this.flowRate);

  factory Valve.createFromFileLine(String fileLine) {
    return Valve(
      fileLine.split('Valve ')[1].split(' ')[0],
      int.parse(fileLine.split('flow rate=')[1].split(';')[0]),
    );
  }

  void addDestinations(List<Valve> valves, String fileLine) {
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
}
