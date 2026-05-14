import 'dart:math';
import '../models/match_prediction.dart';
import '../models/match_stats.dart';

class MatchStatsGenerator {
  static MatchStats generate(MatchPrediction prediction) {
    final random = Random(
      prediction.homeScore * 100 + prediction.awayScore * 10 +
          prediction.homeTeam.overallPower,
    );

    final home = prediction.homeTeam;
    final away = prediction.awayTeam;
    final homeGoals = prediction.homeScore;
    final awayGoals = prediction.awayScore;

    // Possession
    final totalBallControl = home.ballControl + away.ballControl;
    final homePoss = (home.ballControl / totalBallControl * 100);
    final awayPoss = 100 - homePoss;

    // Shots: based on attack power
    final homeBaseShots = (home.attackPower / 10.0).round() + random.nextInt(6) + 3;
    final awayBaseShots = (away.attackPower / 10.0).round() + random.nextInt(6) + 3;
    final homeShots = homeBaseShots.clamp(homeGoals + 2, 22);
    final awayShots = awayBaseShots.clamp(awayGoals + 2, 22);

    // Shots on target
    final homeOnTargetBase = (homeShots * 0.45).round();
    final awayOnTargetBase = (awayShots * 0.45).round();
    final homeShotsOnTarget = homeOnTargetBase.clamp(homeGoals, homeShots);
    final awayShotsOnTarget = awayOnTargetBase.clamp(awayGoals, awayShots);

    // Passes: based on ball control
    final homePasses = (home.ballControl * 4.5).round() + random.nextInt(60) + 200;
    final awayPasses = (away.ballControl * 4.5).round() + random.nextInt(60) + 200;

    // Pass accuracy: based on ball control (range 68%-90%)
    final homePassAcc = (home.ballControl * 0.22 + 68.0).clamp(68.0, 91.0);
    final awayPassAcc = (away.ballControl * 0.22 + 68.0).clamp(68.0, 91.0);

    // Tackles: defensive teams tackle more
    final homeTackles = (home.defensePower * 0.16).round() + random.nextInt(8) + 8;
    final awayTackles = (away.defensePower * 0.16).round() + random.nextInt(8) + 8;

    // Corners: correlated with attack pressure
    final homeCorners = (home.attackPower / 12.0).round() + random.nextInt(5) + 1;
    final awayCorners = (away.attackPower / 12.0).round() + random.nextInt(5) + 1;

    // Fouls
    final homeFouls = random.nextInt(8) + 6;
    final awayFouls = random.nextInt(8) + 6;

    // Cards
    final homeYellowCards = random.nextInt(4);
    final awayYellowCards = random.nextInt(4);
    final homeRedCards = random.nextDouble() < 0.08 ? 1 : 0;
    final awayRedCards = random.nextDouble() < 0.08 ? 1 : 0;

    // Expected Goals (xG): attack vs opponent defense ratio
    final homeXGBase = (home.attackPower - away.defensePower) / 30.0 + 1.2;
    final awayXGBase = (away.attackPower - home.defensePower) / 30.0 + 1.2;
    final homeXG = (homeXGBase + (random.nextDouble() * 0.8 - 0.4)).clamp(0.3, 4.5);
    final awayXG = (awayXGBase + (random.nextDouble() * 0.8 - 0.4)).clamp(0.3, 4.5);

    // Dribbles: attackers with high attack rating
    final homeDribbles = (home.attackPower / 14.0).round() + random.nextInt(7) + 5;
    final awayDribbles = (away.attackPower / 14.0).round() + random.nextInt(7) + 5;

    // Aerial duels
    final homeAerials = random.nextInt(10) + 12;
    final awayAerials = random.nextInt(10) + 12;

    return MatchStats(
      homePossession: homePoss,
      awayPossession: awayPoss,
      homeShots: homeShots,
      awayShots: awayShots,
      homeShotsOnTarget: homeShotsOnTarget,
      awayShotsOnTarget: awayShotsOnTarget,
      homePasses: homePasses,
      awayPasses: awayPasses,
      homePassAccuracy: homePassAcc,
      awayPassAccuracy: awayPassAcc,
      homeTackles: homeTackles,
      awayTackles: awayTackles,
      homeCorners: homeCorners,
      awayCorners: awayCorners,
      homeFouls: homeFouls,
      awayFouls: awayFouls,
      homeYellowCards: homeYellowCards,
      awayYellowCards: awayYellowCards,
      homeRedCards: homeRedCards,
      awayRedCards: awayRedCards,
      homeXG: homeXG,
      awayXG: awayXG,
      homeDribbles: homeDribbles,
      awayDribbles: awayDribbles,
      homeAerialDuels: homeAerials,
      awayAerialDuels: awayAerials,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
    );
  }
}
