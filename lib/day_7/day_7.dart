import 'dart:collection';

import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:collection/collection.dart';

void day7(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(7);

  final allDirectoriesMapped = _day7Read(fileLines);

  final part1 = allDirectoriesMapped.values
      .where((value) => value <= 100000)
      .fold(0, (previousValue, value) => previousValue + value);
  final part2 = allDirectoriesMapped.values
      .where((value) => value > 30000000 - (70000000 - allDirectoriesMapped.values.max)).min;;

  resultReporter.reportResult(7, part1, part2);
}

Map<_Directory, int> _day7Read(List<String> fileLines) {

  final rootDirectory = _Directory(null);
  var currentDirectory = rootDirectory;

  for (var i = 0; i < fileLines.length; i++) {
    final consoleInput = fileLines[i];

    if (consoleInput.isUserCommand()) {
      if (consoleInput.contains('cd')) {
        final splitInput = consoleInput.split(' ');
        final directoryName = splitInput[2];
        if (directoryName == '..') {
          currentDirectory = currentDirectory.parentDirectory!;
        } else if (directoryName != '/') {
          final newDirectory = _Directory(currentDirectory);
          currentDirectory.dirContent.add(newDirectory);
          currentDirectory = newDirectory;
        }
      }
    } else if (fileLines[i - 1].isUserCommand()) {
      var j = i;
      while (fileLines.elementAt(j).isUserCommand() == false) {
        final entry = fileLines[j];
        if (entry.startsWith('dir')) {
          currentDirectory.dirContent.add(_Directory(currentDirectory));
        } else {
          final newFile = _File.createFromConsoleOutput(entry, currentDirectory);
          currentDirectory.dirContent.add(newFile);
        }
        ++j;
        if (j == fileLines.length) {
          break;
        }
      }
    }
  }

  final allDirectorySizesMap = rootDirectory.mapAllSubDirectoryFileSizes(true);
  return allDirectorySizesMap;
}

abstract class _FileSystemEntry {
  final _Directory? parentDirectory;

  _FileSystemEntry(this.parentDirectory);
}

class _Directory extends _FileSystemEntry {
  final dirContent = HashSet<_FileSystemEntry>();

  _Directory(super.parentDirectory);

  Map<_Directory, int> mapAllSubDirectoryFileSizes(bool searchSelf) {
    final directorySizeMap = <_Directory, int>{};

    directorySizeMap[this] = getTotalDirectorySize();

    for (final entry in dirContent) {
      if (entry is _Directory) {
        directorySizeMap.addAll(entry.mapAllSubDirectoryFileSizes(true));
      }
    }

    return directorySizeMap;
  }

  int getTotalDirectorySize() {
    var totalDirectorySize = 0;

    for (final entry in dirContent) {
      if (entry is _File) {
        totalDirectorySize += entry.size;
      } else if (entry is _Directory) {
        totalDirectorySize += entry.getTotalDirectorySize();
      }
    }

    return totalDirectorySize;
  }
}

class _File extends _FileSystemEntry {
  final int size;

  _File(this.size, super.parentDirectory);

  factory _File.createFromConsoleOutput(String consoleLine, _Directory parentDirectory) {
    final split = consoleLine.split(' ');
    return _File(int.parse(split[0]), parentDirectory);
  }
}

extension StringExtensions on String {
  bool isUserCommand() {
    return startsWith('\$');
  }
}
