import 'dart:collection';

import 'package:advent_of_code_2002/util/file_util.dart';
import 'package:collection/collection.dart';

void day7() {
  final fileLines = getInputFileLines(7);

  final allDirectoriesMapped = day7Read(fileLines);

  final part1 = allDirectoriesMapped.values
      .where((value) => value <= 100000)
      .fold(0, (previousValue, value) => previousValue + value);
  final part2 = allDirectoriesMapped.values
      .where((value) => value > 30000000 - (70000000 - allDirectoriesMapped.values.max)).min;;

  print("Day 7 part 1: $part1 part 2: $part2");
}

Map<Directory, int> day7Read(List<String> fileLines) {

  final rootDirectory = Directory(null);
  var currentDirectory = rootDirectory;

  for (int i = 0; i < fileLines.length; i++) {
    final consoleInput = fileLines[i];

    if (consoleInput.isUserCommand()) {
      if (consoleInput.contains('cd')) {
        final splitInput = consoleInput.split(' ');
        final directoryName = splitInput[2];
        if (directoryName == '..') {
          currentDirectory = currentDirectory.parentDirectory!;
        } else if (directoryName != '/') {
          final newDirectory = Directory(currentDirectory);
          currentDirectory.dirContent.add(newDirectory);
          currentDirectory = newDirectory;
        }
      }
    } else if (fileLines[i - 1].isUserCommand()) {
      var j = i;
      while (fileLines.elementAt(j).isUserCommand() == false) {
        final entry = fileLines[j];
        if (entry.startsWith('dir')) {
          currentDirectory.dirContent.add(Directory(currentDirectory));
        } else {
          final newFile = File.createFromConsoleOutput(entry, currentDirectory);
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

abstract class FileSystemEntry {
  final Directory? parentDirectory;

  FileSystemEntry(this.parentDirectory);
}

class Directory extends FileSystemEntry {
  final dirContent = HashSet<FileSystemEntry>();

  Directory(super.parentDirectory);

  Map<Directory, int> mapAllSubDirectoryFileSizes(bool searchSelf) {
    final directorySizeMap = <Directory, int>{};

    directorySizeMap[this] = getTotalDirectorySize();

    for (final entry in dirContent) {
      if (entry is Directory) {
        directorySizeMap.addAll(entry.mapAllSubDirectoryFileSizes(true));
      }
    }

    return directorySizeMap;
  }

  int getTotalDirectorySize() {
    var totalDirectorySize = 0;

    for (final entry in dirContent) {
      if (entry is File) {
        totalDirectorySize += entry.size;
      } else if (entry is Directory) {
        totalDirectorySize += entry.getTotalDirectorySize();
      }
    }

    return totalDirectorySize;
  }
}

class File extends FileSystemEntry {
  final int size;

  File(this.size, super.parentDirectory);

  factory File.createFromConsoleOutput(String consoleLine, Directory parentDirectory) {
    final split = consoleLine.split(' ');
    return File(int.parse(split[0]), parentDirectory);
  }
}

extension StringExtensions on String {
  bool isUserCommand() {
    return startsWith('\$');
  }
}
