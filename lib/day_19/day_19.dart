import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day19(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(19);

  final part1 = _day19Read(fileLines, false);
  final part2 = _day19Read(fileLines, true);

  resultReporter.reportResult(19, part1, part2);
}

int _day19Read(List<String> fileLines, bool part2) {
  final miningFactory = _MiningFactory.fromFileLines(fileLines)..doMining();
  return 1;
}

class _MiningFactory {
  final List<_Blueprint> availableBlueprints;
  final Map<_OreTypes, int> availableOres = {
    _OreTypes.ore: 0,
    _OreTypes.clay: 0,
    _OreTypes.obsidian: 0,
    _OreTypes.geodes: 0,
  };
  final List<_Robot> miningRobots = [_Robot(0, 0, 0, _OreTypes.ore)];

  _MiningFactory(this.availableBlueprints);

  factory _MiningFactory.fromFileLines(List<String> fileLines) {
    return _MiningFactory(
      fileLines.map((e) => _Blueprint.fromFileLine(e)).toList(),
    );
  }

  void doMining() {}
}

class _Blueprint {
  final List<_Robot> robotSpecs;

  _Blueprint(this.robotSpecs);

  factory _Blueprint.fromFileLine(String fileLine) {
    return _Blueprint([]);
  }
}

class _Robot {
  final int oreCost;
  final int clayCost;
  final int obsidianCost;
  final _OreTypes collects;

  _Robot(this.oreCost, this.clayCost, this.obsidianCost, this.collects);
}

enum _OreTypes {
  ore,
  clay,
  obsidian,
  geodes;
}
