import 'dart:math';
import '../models/team.dart';
import '../models/match_prediction.dart';

class PredictionEngine {
  static final Random _random = Random();

  static MatchPrediction predictMatch(Team homeTeam, Team awayTeam) {
    // Calculate expected goals using attack vs defense
    final homeExpectedGoals = _calculateExpectedGoals(
      homeTeam.attackPower,
      awayTeam.defensePower,
    );
    final awayExpectedGoals = _calculateExpectedGoals(
      awayTeam.attackPower,
      homeTeam.defensePower,
    );

    // Add randomness to simulate match variance
    final homeScore = _addRandomness(homeExpectedGoals);
    final awayScore = _addRandomness(awayExpectedGoals);

    // Calculate possession percentage
    final totalBallControl = homeTeam.ballControl + awayTeam.ballControl;
    final possession =
        homeTeam.ballControl / totalBallControl;

    // Calculate win probabilities based on Elo-like logic
    final (homeWinProb, drawProb, awayWinProb) =
        _calculateWinProbabilities(homeScore, awayScore);

    // Determine top scorer
    final topScorer = homeScore > awayScore
        ? homeTeam.players.where((p) => p.position == 'ST').first.name
        : awayTeam.players.where((p) => p.position == 'ST').first.name;

    return MatchPrediction(
      homeTeamName: homeTeam.name,
      awayTeamName: awayTeam.name,
      homeScore: homeScore,
      awayScore: awayScore,
      possession: possession,
      homeWinProbability: homeWinProb,
      drawProbability: drawProb,
      awayWinProbability: awayWinProb,
      topScorer: topScorer,
    );
  }

  static double _calculateExpectedGoals(int attack, int defense) {
    // Simple formula: (attacker - defender) / 20 + base
    final difference = (attack - defense) / 20.0;
    return (1.5 + difference).clamp(0.5, 3.5);
  }

  static int _addRandomness(double baseValue) {
    // Add randomness using Poisson-like distribution
    final baseScore = baseValue.floor();
    final probability = baseValue - baseScore;

    if (_random.nextDouble() < probability) {
      return baseScore + 1;
    }
    return baseScore;
  }

  static (double, double, double) _calculateWinProbabilities(
    int homeScore,
    int awayScore,
  ) {
    final scoreDiff = homeScore - awayScore;

    double homeWinProb;
    double drawProb;
    double awayWinProb;

    if (scoreDiff > 0) {
      homeWinProb = 0.45 + (scoreDiff * 0.15);
      drawProb = 0.20 - (scoreDiff * 0.05);
      awayWinProb = 0.35 - (scoreDiff * 0.10);
    } else if (scoreDiff < 0) {
      homeWinProb = 0.35 - (scoreDiff.abs() * 0.10);
      drawProb = 0.20 - (scoreDiff.abs() * 0.05);
      awayWinProb = 0.45 + (scoreDiff.abs() * 0.15);
    } else {
      homeWinProb = 0.40;
      drawProb = 0.30;
      awayWinProb = 0.30;
    }

    // Normalize to ensure sum = 1.0
    final total = homeWinProb + drawProb + awayWinProb;
    return (
      (homeWinProb / total).clamp(0.0, 1.0),
      (drawProb / total).clamp(0.0, 1.0),
      (awayWinProb / total).clamp(0.0, 1.0),
    );
  }
}
