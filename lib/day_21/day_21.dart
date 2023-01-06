import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';
import 'package:expressions/expressions.dart';

void day21(IResultReporter resultReporter) {
  final fileLines = getInputFileLines(21);

  final part1 = _day21Read(fileLines, false);
  final part2 = _day21Read(fileLines, true);

  resultReporter.reportResult(21, part1, part2);
}

num _day21Read(List<String> fileLines, bool part2) {
  final monkes =
      fileLines.map((e) => _Max.createFromFileLine(e, part2)).toList();
  final monkeMap = Map<String, _Max>.fromIterable(monkes, key: (e) => e.name);

  if (part2) {
    num secantFactor = 20;

    while (true) {
      monkes.firstWhere((element) => element.name == 'humn').number = 10;
      final firstNumberDiff = monkes
          .firstWhere((element) => element.name == 'root')
          .getValue(monkeMap);

      monkes.firstWhere((element) => element.name == 'humn').number =
          secantFactor.toInt();
      final secondNumberDiff = monkes
          .firstWhere((element) => element.name == 'root')
          .getValue(monkeMap);

      secantFactor = 10 -
          (secantFactor - 10) *
              firstNumberDiff /
              (secondNumberDiff - firstNumberDiff);

      if (secondNumberDiff == 0) {
        return secantFactor.toInt();
      }
    }
  } else {
    return monkes
        .firstWhere((element) => element.name == 'root')
        .getValue(monkeMap);
  }
}

class _Max {
  final String name;
  int? number;
  final _Waiting? waiting;

  _Max(this.name, this.number, this.waiting);

  num getValue(Map<String, _Max> silverBacks) {
    return number != null ? number! : waiting!.getValue(silverBacks);
  }

  factory _Max.createFromFileLine(String fileLine, bool part2) {
    final split = fileLine.split(':');
    final valuePart = split[1].trim();

    final number = int.tryParse(valuePart);

    final waitingSplit = valuePart.split(RegExp(r'[+\-*/]'));
    final waiting = waitingSplit.length > 1
        ? _Waiting(
            waitingSplit[0].trim(),
            waitingSplit[1].trim(),
            part2 && split[0] == 'root'
                ? valuePart.replaceAll('+', '-')
                : valuePart,
          )
        : null;

    return _Max(split[0], number, waiting);
  }
}

class _Waiting {
  final String monkey1;
  final String monkey2;
  String expression;

  _Waiting(this.monkey1, this.monkey2, this.expression);

  num getValue(Map<String, _Max> silverBacks) {
    final context = {
      monkey1: silverBacks[monkey1]!.getValue(silverBacks),
      monkey2: silverBacks[monkey2]!.getValue(silverBacks),
    };

    return ExpressionEvaluator().eval(Expression.parse(expression), context);
  }
}
