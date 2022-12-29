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
  final List<_Robot> miningRobots = [_Robot(0, 0, 0, _OreType.ore)];

  _MiningFactory(this.availableBlueprints);

  factory _MiningFactory.fromFileLines(List<String> fileLines) {
    return _MiningFactory(
      fileLines.map((e) => _Blueprint.fromFileLine(e)).toList(),
    );
  }

  int calculateBlueprintScore(
    _Blueprint blueprint,
    int minutes,
    _OreType action,
    Map<_State, int> cache,
    List<_Robot> workingMiners,
    Map<_OreType, int> minedOres,
  ) {
    int traverseRemaining(int minutes) {
      final availableActions = blueprint.availableActions(minedOres);

      return availableActions
              .map(
                (e) => calculateBlueprintScore(
                  blueprint,
                  minutes - 1,
                  e,
                  cache,
                  [...workingMiners],
                  Map.from(minedOres),
                ),
              )
              .sorted((a, b) => a.compareTo(b))
              .lastOrNull ??
          0;
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

    for (final miner in workingMiners) {
      minedOres[miner.collects] = minedOres[miner.collects]! + 1;
    }

    if (minerBeingBuilt != null) {
      workingMiners.add(minerBeingBuilt);
    }

    final currentScore = minedOres[_OreType.geodes]!;
    final currentState = _State(minutes, workingMiners, minedOres, action);

    if (minutes <= 0 || cache.containsKey(currentState)) {
      return cache[currentState] ?? currentScore;
    }

    final spentThisMinute = traverseRemaining(minutes);
    cache[currentState] = spentThisMinute;
    return currentScore + cache[currentState]!;
  }

  int doMining() {
    final bestBlueprint = availableBlueprints
        .mapIndexed(
          (index, e) =>
              calculateBlueprintScore(
                e,
                24,
                _OreType.none,
                {},
                miningRobots,
                availableOres,
              ) *
              (index + 1),
        )
        .max;
    return bestBlueprint;
  }
}

class _Blueprint {
  final List<_Robot> robotSpecs;

  _Blueprint(this.robotSpecs);

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

    return _Blueprint([oreRobot, clayRobot, obsidianRobot, geodeRobot]);
  }

  List<_OreType> availableActions(Map<_OreType, int> minedOres) {
    bool canAffordRobot(_Robot spec, Map<_OreType, int> minedOres) {
      return minedOres[_OreType.ore]! >= spec.oreCost &&
          minedOres[_OreType.clay]! >= spec.clayCost &&
          minedOres[_OreType.obsidian]! >= spec.obsidianCost;
    }

    return robotSpecs
        .where((spec) => canAffordRobot(spec, minedOres))
        .map((e) => e.collects)
        .toList()
      ..add(_OreType.none);
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
  final List<_Robot> miners;
  Map<_OreType, int> minedOres;
  _OreType action;

  _State(
    this.time,
    this.miners,
    this.minedOres,
    this.action,
  );

  @override
  bool operator ==(Object other) {
    if (other is _State) {
      return areMapsEqual(minedOres, other.minedOres) &&
          time == other.time &&
          action == other.action &&
          miners.every((element) => other.miners.contains(element));
    }
    return false;
  }

  @override
  int get hashCode {
    var result = minedOres.hashCode ^ time.hashCode ^ action.hashCode;
    for (final element in miners) {
      result = 31 * result + element.hashCode;
    }
    return result;
  }
}
