import 'package:advent_of_code_2022/util/file_util.dart';
import 'package:advent_of_code_2022/util/result_reporter.dart';

void day2(IResultReporter resultReporter) {
  final inputFileLines = getInputFileLines(2);

  var totalScoreFromAllRounds = 0;
  var totalScoreFromAllRounds_part2 = 0;

  for (final line in inputFileLines) {
    final lineSplit = line.split(' ');

    final opponentChoice = _RockPaperScissors.fromLetter(lineSplit.first);
    final myChoice = _RockPaperScissors.fromLetter(lineSplit[1]);

    final roundScoreDiff = myChoice.value / opponentChoice.value;
    roundScore(){if (myChoice.value == opponentChoice.value) {
      return 3;
    } else if (roundScoreDiff < 0.5 || (roundScoreDiff >= 1.5 && roundScoreDiff < 3)) {
      return 6;
    } else {
      return 0;
    }}

    final totalRoundScore = myChoice.value + roundScore();

    totalScoreFromAllRounds += totalRoundScore;
    totalScoreFromAllRounds_part2 += _day2Bonus(opponentChoice, myChoice);
  }

  resultReporter.reportResult(2, totalScoreFromAllRounds, totalScoreFromAllRounds_part2);
}

enum _RockPaperScissors {
  rock(1, 'X', 'A'),
  paper(2, 'Y', 'B'),
  scissors(3, 'Z', 'C');

  final int value;
  final String myLetter;
  final String opponentLetter;

  const _RockPaperScissors(this.value, this.myLetter, this.opponentLetter);

  factory _RockPaperScissors.fromLetter(String letter) {
    if (letter == 'A' || letter == 'X') {
      return _RockPaperScissors.rock;
    } else if (letter == 'B' || letter == 'Y') {
      return _RockPaperScissors.paper;
    } else {
      return _RockPaperScissors.scissors;
    }
  }
}

int _day2Bonus(_RockPaperScissors opponentChoice, _RockPaperScissors myChoice) {
  if (myChoice == _RockPaperScissors.rock) {
    return opponentChoice.value - 1 == 0 ? 3 : opponentChoice.value - 1;
  } else if (myChoice == _RockPaperScissors.paper) {
    return 3 + opponentChoice.value;
  } else {
    return 6 + (opponentChoice.value + 1 == 4 ? 1 : opponentChoice.value + 1);
  }
}