import 'dart:collection';
import 'dart:math';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/generic.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day19(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(19);

  final part1 = _day19Read(fileLines, false);
  final part2 = 2; //_day19Read(fileLines, true);

  resultReporter.reportResult(19, part1, part2);
}

int _day19Read(List<String> fileLines, bool part2) {
  final miningFactory = _MiningFactory.fromFileLines(fileLines);
  return miningFactory.doMining();
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

  Map<int, _State> calculateBlueprintScore(
    _Blueprint blueprint,
    int remainingMinutes,
    _OreType action,
    Map<int, _State> bestStateAtMinute,
    Map<_OreType, int> workingMiners,
    Map<_OreType, int> minedOres,
  ) {
    void traverseRemaining(int minutes) {
      final availableActions = blueprint.availableActions(
          minedOres, workingMiners, remainingMinutes);

      availableActions
        ..forEach(
          (e) => calculateBlueprintScore(
            blueprint,
            minutes - 1,
            e,
            bestStateAtMinute,
            Map.from(workingMiners),
            Map.from(minedOres),
          ),
        );
    }

    final minerBeingBuilt = blueprint.robotSpecs
        .firstWhereOrNull((element) => element.collects == action);

    if (minerBeingBuilt != null) {
      minedOres[_OreType.ore] =
          minedOres[_OreType.ore]! - minerBeingBuilt.oreCost;
      minedOres[_OreType.clay] =
          minedOres[_OreType.clay]! - minerBeingBuilt.clayCost;
      minedOres[_OreType.obsidian] =
          minedOres[_OreType.obsidian]! - minerBeingBuilt.obsidianCost;
    }

    for (final miner in workingMiners.entries) {
      minedOres[miner.key] = minedOres[miner.key]! + workingMiners[miner.key]!;
    }

    if (minerBeingBuilt != null) {
      workingMiners[minerBeingBuilt.collects] =
          workingMiners[minerBeingBuilt.collects]! + 1;
    }

    final currentState =
        _State(remainingMinutes, workingMiners, minedOres, action);

    if (remainingMinutes == 0 ||
        currentState.calculateStateScore(blueprint) <
            (bestStateAtMinute[remainingMinutes]
                    ?.calculateStateScore(blueprint) ??
                -1) ||
        bestStateAtMinute[remainingMinutes] == currentState) {
      if (currentState.calculateStateScore(blueprint) >
          (bestStateAtMinute[remainingMinutes]
                  ?.calculateStateScore(blueprint) ??
              -1)) {
        bestStateAtMinute[remainingMinutes] = currentState;
      }

      return bestStateAtMinute;
    }

    traverseRemaining(remainingMinutes);

    if (currentState.calculateStateScore(blueprint) >
        (bestStateAtMinute[remainingMinutes]?.calculateStateScore(blueprint) ??
            -1)) {
      bestStateAtMinute[remainingMinutes] = currentState;
    }

    return bestStateAtMinute;
  }

  int doMining() {
    final bestBluePrints = [];

    availableBlueprints.forEachIndexed((index, element) {
      print(index);
      final bestStateScores = calculateBlueprintScore(
        element,
        23,
        _OreType.none,
        {},
        Map.from(miningRobots),
        Map.from(availableOres),
      );
      bestBluePrints.add(bestStateScores);
    });

    final bluePrintScore = bestBluePrints
        .mapIndexed(
          (index, element) =>
              element[0]!.minedOres[_OreType.geodes]! * (index + 1),
        )
        .toList();
    return bluePrintScore.reduce((value, element) => value + element);
  }
}

class _Blueprint {
  final List<_Robot> robotSpecs;
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

    final robotList = [oreRobot, clayRobot, obsidianRobot, geodeRobot];

    return _Blueprint(robotList, {
      _OreType.ore: robotList
          .sorted((a, b) => a.oreCost.compareTo(b.oreCost))
          .last
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

  bool canAffordRobot(_Robot spec, Map<_OreType, int> minedOres) {
    return minedOres[_OreType.ore]! >= spec.oreCost &&
        minedOres[_OreType.clay]! >= spec.clayCost &&
        minedOres[_OreType.obsidian]! >= spec.obsidianCost;
  }

  List<_OreType> availableActions(
    Map<_OreType, int> minedOres,
    Map<_OreType, int> workingMiners,
    int remainingMinutes,
  ) {
    final actions = robotSpecs
        .where((spec) => canAffordRobot(spec, minedOres))
        .map((e) => e.collects)
        .toList()
      ..removeWhere(
        (element) =>
            (minedOres[element] ?? -1) *
                    workingMiners[element]! /
                    highestOreCost[element]! >=
                remainingMinutes,
      );

    if (!actions.contains(_OreType.geodes)) {
      actions.add(_OreType.none);
    }

    return actions;
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
  final int time;
  Map<_OreType, int> miners;
  Map<_OreType, int> minedOres;
  _OreType action;

  _State(
    this.time,
    this.miners,
    this.minedOres,
    this.action,
  );

  int calculateStateScore(_Blueprint _blueprint) {
    return miners[_OreType.geodes]! * time + minedOres[_OreType.geodes]!;
  }

  @override
  bool operator ==(Object other) {
    if (other is _State) {
      return areMapsEqual(minedOres, other.minedOres) &&
          time == other.time &&
          action == other.action &&
          areMapsEqual(miners, other.miners);
    }
    return false;
  }

  @override
  int get hashCode {
    var result = minedOres.hashCode ^ time.hashCode ^ action.hashCode;
    for (final element in miners.entries) {
      result = result ^ element.key.hashCode ^ element.value.hashCode;
    }
    for (final element in minedOres.entries) {
      result = result ^ element.key.hashCode ^ element.value.hashCode;
    }
    return result;
  }
}
