class LeagueStanding {
  final int position;
  final String teamName;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  LeagueStanding({
    required this.position,
    required this.teamName,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  String get qualification {
    if (position <= 4) return 'CL';
    if (position <= 6) return 'EL';
    if (position == 7) return 'ECL';
    if (position >= 18) return 'REL';
    return '';
  }
}
