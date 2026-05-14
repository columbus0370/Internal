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
  });

  String get result {
    if (homeScore > awayScore) return 'Home Win';
    if (awayScore > homeScore) return 'Away Win';
    return 'Draw';
  }

  int get totalShots => (homeScore + awayScore) * 3 + (5 + 4);
}
