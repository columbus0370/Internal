import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_prediction.dart';
import '../models/team.dart';

class MatchPredictionResult {
  final int homeScore;
  final int awayScore;
  final String homeTeamMom;
  final String awayTeamMom;
  final List<GoalEvent> goals;
  final MatchStats stats;
  final List<String> highlights;

  MatchPredictionResult({
    required this.homeScore,
    required this.awayScore,
    required this.homeTeamMom,
    required this.awayTeamMom,
    required this.goals,
    required this.stats,
    required this.highlights,
  });

  factory MatchPredictionResult.fromJson(Map<String, dynamic> json) {
    final goalsList = (json['goals'] as List<dynamic>? ?? []).map((g) {
      return GoalEvent(
        minute: "${g['minute']}'",
        team: g['team'] == 'home' ? 'Home' : 'Away',
        scorer: g['scorer'],
        assist: g['assist'],
      );
    }).toList();

    final homeStats = json['stats']['home'] as Map<String, dynamic>;
    final awayStats = json['stats']['away'] as Map<String, dynamic>;

    final stats = MatchStats(
      homeGoals: json['homeScore'],
      awayGoals: json['awayScore'],
      homeShots: homeStats['shots'] ?? 0,
      awayShots: awayStats['shots'] ?? 0,
      homeShotsOnTarget: homeStats['onTarget'] ?? 0,
      awayShotsOnTarget: awayStats['onTarget'] ?? 0,
      homePossession: (homeStats['possession'] ?? 50).toDouble(),
      awayPossession: (awayStats['possession'] ?? 50).toDouble(),
      homePasses: homeStats['passes'] ?? 400,
      awayPasses: awayStats['passes'] ?? 400,
      homePassAccuracy: homeStats['passAccuracy'] ?? 80.0,
      awayPassAccuracy: awayStats['passAccuracy'] ?? 80.0,
      homeTackles: homeStats['tackles'] ?? 15,
      awayTackles: awayStats['tackles'] ?? 15,
      homeAerialDuels: homeStats['aerialDuels'] ?? 20,
      awayAerialDuels: awayStats['aerialDuels'] ?? 20,
      homeFouls: homeStats['fouls'] ?? 10,
      awayFouls: awayStats['fouls'] ?? 10,
      homeYellowCards: homeStats['yellowCards'] ?? 2,
      awayYellowCards: awayStats['yellowCards'] ?? 2,
      homeRedCards: homeStats['redCards'] ?? 0,
      awayRedCards: awayStats['redCards'] ?? 0,
      homeXG: (homeStats['xg'] ?? 1.5).toDouble(),
      awayXG: (awayStats['xg'] ?? 1.2).toDouble(),
      homeCorners: homeStats['corners'] ?? 5,
      awayCorners: awayStats['corners'] ?? 4,
      homeDribbles: homeStats['dribbles'] ?? 25,
      awayDribbles: awayStats['dribbles'] ?? 18,
    );

    return MatchPredictionResult(
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      homeTeamMom: json['homeTeamMom'],
      awayTeamMom: json['awayTeamMom'],
      goals: goalsList,
      stats: stats,
      highlights: List<String>.from(json['highlights'] ?? []),
    );
  }
}

class MatchStats {
  final int homeGoals;
  final int awayGoals;
  final int homeShots;
  final int awayShots;
  final int homeShotsOnTarget;
  final int awayShotsOnTarget;
  final double homePossession;
  final double awayPossession;
  final int homePasses;
  final int awayPasses;
  final double homePassAccuracy;
  final double awayPassAccuracy;
  final int homeTackles;
  final int awayTackles;
  final int homeAerialDuels;
  final int awayAerialDuels;
  final int homeFouls;
  final int awayFouls;
  final int homeYellowCards;
  final int awayYellowCards;
  final int homeRedCards;
  final int awayRedCards;
  final double homeXG;
  final double awayXG;
  final int homeCorners;
  final int awayCorners;
  final int homeDribbles;
  final int awayDribbles;

  MatchStats({
    required this.homeGoals,
    required this.awayGoals,
    required this.homeShots,
    required this.awayShots,
    required this.homeShotsOnTarget,
    required this.awayShotsOnTarget,
    required this.homePossession,
    required this.awayPossession,
    required this.homePasses,
    required this.awayPasses,
    required this.homePassAccuracy,
    required this.awayPassAccuracy,
    required this.homeTackles,
    required this.awayTackles,
    required this.homeAerialDuels,
    required this.awayAerialDuels,
    required this.homeFouls,
    required this.awayFouls,
    required this.homeYellowCards,
    required this.awayYellowCards,
    required this.homeRedCards,
    required this.awayRedCards,
    required this.homeXG,
    required this.awayXG,
    required this.homeCorners,
    required this.awayCorners,
    required this.homeDribbles,
    required this.awayDribbles,
  });
}

class AIMatchPredictor {
  static const String _proxyEndpoint = String.fromEnvironment('API_PROXY_URL', defaultValue: 'http://localhost:3000');

  static Future<MatchPredictionResult> predictMatch(Team homeTeam, Team awayTeam) async {
    try {
      final response = await http.post(
        Uri.parse('$_proxyEndpoint/api/predict-match'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'homeTeam': {
            'name': homeTeam.name,
            'attackPower': homeTeam.attackPower,
            'defensePower': homeTeam.defensePower,
            'ballControl': homeTeam.ballControl,
            'formation': homeTeam.formation,
            'players': homeTeam.players.map((p) => {
              'name': p.name,
              'position': p.position,
            }).toList(),
          },
          'awayTeam': {
            'name': awayTeam.name,
            'attackPower': awayTeam.attackPower,
            'defensePower': awayTeam.defensePower,
            'ballControl': awayTeam.ballControl,
            'formation': awayTeam.formation,
            'players': awayTeam.players.map((p) => {
              'name': p.name,
              'position': p.position,
            }).toList(),
          },
        }),
      );

      if (response.statusCode == 200) {
        final matchJson = jsonDecode(response.body);
        return MatchPredictionResult.fromJson(matchJson);
      } else {
        final error = jsonDecode(response.body);
        throw Exception('API Error: ${error['error'] ?? response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
