class Team {
  final String id;
  final String name;
  final int leagueRank;
  final int overallPower;
  final int attackPower;
  final int defensePower;
  final int ballControl;
  final List<Player> players;
  final String formation;

  Team({
    required this.id,
    required this.name,
    required this.leagueRank,
    required this.overallPower,
    required this.attackPower,
    required this.defensePower,
    required this.ballControl,
    required this.players,
    this.formation = '4-3-3',
  });
}

class Player {
  final String name;
  final String position;
  final int overallRating;
  final int attackRating;
  final int defenseRating;
  final int passingRating;

  Player({
    required this.name,
    required this.position,
    required this.overallRating,
    required this.attackRating,
    required this.defenseRating,
    required this.passingRating,
  });
}
