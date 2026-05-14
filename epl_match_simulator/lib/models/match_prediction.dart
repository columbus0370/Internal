class GoalEvent {
  final String minute;
  final String team;
  final String scorer;
  final String? assist;

  GoalEvent({
    required this.minute,
    required this.team,
    required this.scorer,
    this.assist,
  });
}

class MatchPrediction {
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final double possession;
  final double homeWinProbability;
  final double drawProbability;
  final double awayWinProbability;
  final String topScorer;
  final String mom;
  final List<GoalEvent> goals;

  MatchPrediction({
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeScore,
    required this.awayScore,
    required this.possession,
    required this.homeWinProbability,
    required this.drawProbability,
    required this.awayWinProbability,
    required this.topScorer,
    required this.mom,
    required this.goals,
  });

  String get result {
    if (homeScore > awayScore) return 'Home Win';
    if (awayScore > homeScore) return 'Away Win';
    return 'Draw';
  }

  int get totalShots => (homeScore + awayScore) * 3 + (5 + 4);
}
