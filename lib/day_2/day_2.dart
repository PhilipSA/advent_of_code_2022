import 'dart:io';

import 'package:advent_of_code_2022/util/file_util.dart';

enum RockPaperScissors {
  rock(1, 'X', 'A'),
  paper(2, 'Y', 'B'),
  scissors(3, 'Z', 'C');

  final int value;
  final String myLetter;
  final String opponentLetter;

  const RockPaperScissors(this.value, this.myLetter, this.opponentLetter);

  factory RockPaperScissors.fromLetter(String letter) {
    if (letter == 'A' || letter == 'X') {
      return RockPaperScissors.rock;
    } else if (letter == 'B' || letter == 'Y') {
      return RockPaperScissors.paper;
    } else {
      return RockPaperScissors.scissors;
    }
  }
}

class Rounds {
  final RockPaperScissors myChoice;
  final RockPaperScissors opponentChoice;

  Rounds(this.myChoice, this.opponentChoice);
}

int day2() {
  final inputFileLines = getInputFileLines(2);

  var totalScoreFromAllRounds = 0;
  var totalScoreFromAllRounds_part2 = 0;

  for (final line in inputFileLines) {
    final lineSplit = line.split(' ');

    final opponentChoice = RockPaperScissors.fromLetter(lineSplit.first);
    final myChoice = RockPaperScissors.fromLetter(lineSplit[1]);

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
    totalScoreFromAllRounds_part2 += day2Bonus(opponentChoice, myChoice);
  }

  return totalScoreFromAllRounds;
}

int day2Bonus(RockPaperScissors opponentChoice, RockPaperScissors myChoice) {
  if (myChoice == RockPaperScissors.rock) {
    return opponentChoice.value - 1 == 0 ? 3 : opponentChoice.value - 1;
  } else if (myChoice == RockPaperScissors.paper) {
    return 3 + opponentChoice.value;
  } else {
    return 6 + (opponentChoice.value + 1 == 4 ? 1 : opponentChoice.value + 1);
  }
}