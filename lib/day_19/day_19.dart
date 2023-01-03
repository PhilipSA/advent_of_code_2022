import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/generic.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day19(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(19);

  final part1 = _day19Read(fileLines, false);
  final part2 = _day19Read(fileLines, true);

  resultReporter.reportResult(19, part1, part2);
}

int _day19Read(List<String> fileLines, bool part2) {
  final miningFactory = _MiningFactory.fromFileLines(fileLines);
  return miningFactory.doMining(part2);
}

class _MiningFactory {
  final List<_Blueprint> availableBlueprints;
  final Map<_OreType, int> availableOres = {
    _OreType.ore: 0,
    _OreType.clay: 0,
    _OreType.obsidian: 0,
    _OreType.geodes: 0,
  };
  final Map<_OreType, int> miningRobots = {
    _OreType.ore: 1,
    _OreType.clay: 0,
    _OreType.obsidian: 0,
    _OreType.geodes: 0,
  };

  _MiningFactory(this.availableBlueprints);

  factory _MiningFactory.fromFileLines(List<String> fileLines) {
    return _MiningFactory(
      fileLines.map((e) => _Blueprint.fromFileLine(e)).toList(),
    );
  }

  int bfs(_State initialState, _Blueprint blueprint) {
    final queue = Queue<_State>();
    final visited = HashSet<_State>();
    final bestState = <int, _State>{};
    var exploredStates = 0;
    var maxGeodes = -1;

    queue.add(initialState);

    while (!queue.isEmpty) {
      ++exploredStates;
      // Remove the node from the front of the queue
      final currentState = queue.removeFirst();

      if (visited.contains(currentState)) {
        continue;
      }
      visited.add(currentState);

      final minerBeingBuilt = blueprint.robotSpecs.firstWhereOrNull(
        (element) => element.collects == currentState.action,
      );

      //Start building a new robot
      if (minerBeingBuilt != null) {
        currentState
          ..ore -= minerBeingBuilt.oreCost
          ..clay -= minerBeingBuilt.clayCost
          ..obsidian -= minerBeingBuilt.obsidianCost;
      }

      //Do some mining
      currentState
        ..ore += currentState.oreRobots
        ..clay += currentState.clayRobots
        ..obsidian += currentState.obsidianRobots
        ..geodes += currentState.geodeRobots;

      //Build the robot
      if (minerBeingBuilt != null) {
        switch (minerBeingBuilt.collects) {
          case _OreType.ore:
            ++currentState.oreRobots;
            break;
          case _OreType.clay:
            ++currentState.clayRobots;
            break;
          case _OreType.obsidian:
            ++currentState.obsidianRobots;
            break;
          case _OreType.geodes:
            ++currentState.geodeRobots;
            break;
          case _OreType.none:
            break;
        }
      }

      //Track best state for this minute
      if (currentState.geodes > (bestState[currentState.time]?.geodes ?? -1)) {
        bestState[currentState.time] = currentState;
      }

      //Cutoff
      if (currentState.time == 0) {
        maxGeodes = max(maxGeodes, currentState.geodes);
        continue;
      }

      // Explore available actions
      for (final action in blueprint.availableActions(currentState)) {
        final newState = _State(
          ore: currentState.ore,
          clay: currentState.clay,
          obsidian: currentState.obsidian,
          geodes: currentState.geodes,
          oreRobots: currentState.oreRobots,
          clayRobots: currentState.clayRobots,
          obsidianRobots: currentState.obsidianRobots,
          geodeRobots: currentState.geodeRobots,
          time: currentState.time - 1,
          action: action,
        );
        if (!visited.contains(newState)) {
          queue.add(newState);
        }
      }
    }

    print('Explored states: $exploredStates');
    return maxGeodes;
  }

  int doMining(bool part2) {
    final bestBlueprint = availableBlueprints
        .take(part2 ? 3 : availableBlueprints.length)
        .mapIndexed(
      (index, e) {
        print(index);
        return bfs(
          _State(oreRobots: 1),
          e,
        );
      },
    ).toList();

    if (part2) {
      return bestBlueprint.reduce((value, element) => value * element);
    }

    final bluePrintScore = bestBlueprint
        .mapIndexed(
          (index, element) => element * (index + 1),
        )
        .toList();
    return bluePrintScore.reduce((value, element) => value + element);
  }
}

class _Blueprint {
  final Set<_Robot> robotSpecs;
  final Map<_OreType, int> highestOreCost;

  _Blueprint(this.robotSpecs, this.highestOreCost);

  factory _Blueprint.fromFileLine(String fileLine) {
    final robotCosts = fileLine.split(':')[1].split('.');

    final regex = RegExp(r'\d+\s+(ore|clay|obsidian)');

    int getCostForInput(int robotIndex) {
      return int.parse(
        regex.firstMatch(robotCosts[robotIndex])!.group(0)!.split(' ')[0],
      );
    }

    final oreRobot = _Robot(getCostForInput(0), 0, 0, _OreType.ore);
    final clayRobot = _Robot(getCostForInput(1), 0, 0, _OreType.clay);
    final obsidianRobot = _Robot(
      getCostForInput(2),
      int.parse(
        regex.allMatches(robotCosts[2]).toList()[1].group(0)!.split(' ')[0],
      ),
      0,
      _OreType.obsidian,
    );
    final geodeRobot = _Robot(
      getCostForInput(3),
      0,
      int.parse(
        regex.allMatches(robotCosts[3]).toList()[1].group(0)!.split(' ')[0],
      ),
      _OreType.geodes,
    );

    final robotList = {oreRobot, clayRobot, obsidianRobot, geodeRobot};

    return _Blueprint(robotList, {
      _OreType.ore: robotList
          .sorted((a, b) => a.oreCost.compareTo(b.oreCost))
          .lastWhere((element) => element.collects != _OreType.ore)
          .oreCost,
      _OreType.clay: robotList
          .sorted((a, b) => a.clayCost.compareTo(b.clayCost))
          .last
          .clayCost,
      _OreType.obsidian: robotList
          .sorted((a, b) => a.obsidianCost.compareTo(b.obsidianCost))
          .last
          .obsidianCost,
      _OreType.none: 10000000,
      _OreType.geodes: 1000000,
    });
  }

  bool shouldBuildRobot(_Robot spec, _State state) {
    final canAffordRobot = spec.oreCost <= state.ore &&
        spec.clayCost <= state.clay &&
        spec.obsidianCost <= state.obsidian;

    if (spec.collects == _OreType.ore) {
      return (highestOreCost[spec.collects]! >= state.oreRobots ||
              (state.ore + state.oreRobots * state.time) /
                      highestOreCost[spec.collects]! >=
                  state.time) &&
          canAffordRobot;
    }
    if (spec.collects == _OreType.clay) {
      return (highestOreCost[spec.collects]! >= state.clayRobots ||
              (state.ore + state.clayRobots * state.time) /
                      highestOreCost[spec.collects]! >=
                  state.time) &&
          canAffordRobot;
    }
    if (spec.collects == _OreType.obsidian) {
      return (highestOreCost[spec.collects]! >= state.obsidianRobots ||
              (state.ore + state.obsidianRobots * state.time) /
                      highestOreCost[spec.collects]! >=
                  state.time) &&
          canAffordRobot;
    }
    if (spec.collects == _OreType.geodes) {
      return canAffordRobot;
    }

    return canAffordRobot;
  }

  Set<_OreType> availableActions(_State state) {
    final buildableRobots = robotSpecs
        .where(
          (spec) => shouldBuildRobot(spec, state),
        )
        .map((e) => e.collects)
        .toSet();

    buildableRobots.add(_OreType.none);

    return buildableRobots;
  }
}

class _Robot {
  final int oreCost;
  final int clayCost;
  final int obsidianCost;
  final _OreType collects;

  _Robot(this.oreCost, this.clayCost, this.obsidianCost, this.collects);

  @override
  bool operator ==(Object other) {
    if (other is _Robot) {
      return collects == other.collects;
    }
    return false;
  }

  @override
  int get hashCode {
    return collects.hashCode;
  }
}

enum _OreType {
  ore,
  clay,
  obsidian,
  geodes,
  none;
}

class _State {
  int ore;
  int clay;
  int obsidian;
  int geodes;
  int oreRobots;
  int clayRobots;
  int obsidianRobots;
  int geodeRobots;
  final int time;
  final _OreType action;

  _State({
    this.ore = 0,
    this.clay = 0,
    this.obsidian = 0,
    this.geodes = 0,
    this.oreRobots = 0,
    this.clayRobots = 0,
    this.obsidianRobots = 0,
    this.geodeRobots = 0,
    this.time = 24,
    this.action = _OreType.none,
  });

  @override
  bool operator ==(Object other) {
    if (other is _State) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode {
    return ore.hashCode ^
        clay.hashCode ^
        obsidian.hashCode ^
        geodes.hashCode ^
        oreRobots.hashCode ^
        clayRobots.hashCode ^
        obsidianRobots.hashCode ^
        geodeRobots.hashCode ^
        time.hashCode ^
        action.hashCode;
  }
}
