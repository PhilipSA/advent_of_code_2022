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
  final monkes = fileLines.map((e) => _Max.createFromFileLine(e)).toList();
  return monkes
      .firstWhere((element) => element.name == 'root')
      .getValue(Map.fromIterable(monkes, key: (e) => e.name));
}

class _Max {
  final String name;
  final int? number;
  final _Waiting? waiting;

  _Max(this.name, this.number, this.waiting);

  num getValue(Map<String, _Max> silverBacks) {
    return number != null ? number! : waiting!.getValue(silverBacks);
  }

  factory _Max.createFromFileLine(String fileLine) {
    final split = fileLine.split(':');
    final valuePart = split[1].trim();

    final number = int.tryParse(valuePart);

    final waitingSplit = valuePart.split(RegExp(r'[+\-*/]'));
    final waiting = waitingSplit.length > 1
        ? _Waiting(waitingSplit[0].trim(), waitingSplit[1].trim(), valuePart)
        : null;

    return _Max(split[0], number, waiting);
  }
}

class _Waiting {
  final String monkey1;
  final String monkey2;
  final String expression;

  _Waiting(this.monkey1, this.monkey2, this.expression);

  num getValue(Map<String, _Max> silverBacks) {
    final context = {
      monkey1: silverBacks[monkey1]!.getValue(silverBacks),
      monkey2: silverBacks[monkey2]!.getValue(silverBacks),
    };

    return ExpressionEvaluator().eval(Expression.parse(expression), context);
  }
}
