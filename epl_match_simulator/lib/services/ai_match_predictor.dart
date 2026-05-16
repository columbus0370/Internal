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
  static const String _apiKey = String.fromEnvironment('CLAUDE_API_KEY', defaultValue: '');
  static const String _apiEndpoint = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-6';
  static const String _apiVersion = '2024-06-01';

  static Future<MatchPredictionResult> predictMatch(Team homeTeam, Team awayTeam) async {
    if (_apiKey.isEmpty) {
      throw Exception('CLAUDE_API_KEY is not configured');
    }

    try {
      final prompt = _buildPredictionPrompt(homeTeam, awayTeam);

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1500,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['content'][0]['text'] as String;

        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch == null) {
          throw Exception('No JSON found in response');
        }

        final matchJson = jsonDecode(jsonMatch.group(0)!);
        return MatchPredictionResult.fromJson(matchJson);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static String _buildPredictionPrompt(Team homeTeam, Team awayTeam) {
    return '''
You are an expert football analyst. Predict a Premier League match between ${homeTeam.name} and ${awayTeam.name}.

HOME TEAM: ${homeTeam.name}
- Attack Power: ${homeTeam.attackPower}
- Defense Power: ${homeTeam.defensePower}
- Ball Control: ${homeTeam.ballControl}
- Formation: ${homeTeam.formation}
- Key Players: ${homeTeam.players.take(5).map((p) => p.name).join(', ')}

AWAY TEAM: ${awayTeam.name}
- Attack Power: ${awayTeam.attackPower}
- Defense Power: ${awayTeam.defensePower}
- Ball Control: ${awayTeam.ballControl}
- Formation: ${awayTeam.formation}
- Key Players: ${awayTeam.players.take(5).map((p) => p.name).join(', ')}

Return ONLY a valid JSON object (no additional text) with this exact structure:
{
  "homeScore": <int>,
  "awayScore": <int>,
  "homeTeamMom": "<player name>",
  "awayTeamMom": "<player name>",
  "goals": [
    {"minute": <int 1-90>, "team": "home" or "away", "scorer": "<player name>", "assist": "<player name or null>"}
  ],
  "stats": {
    "home": {
      "possession": <int 30-70>,
      "shots": <int 8-20>,
      "onTarget": <int 2-10>,
      "passes": <int 300-600>,
      "passAccuracy": <float 75-95>,
      "tackles": <int 10-25>,
      "aerialDuels": <int 15-30>,
      "fouls": <int 5-20>,
      "yellowCards": <int 0-5>,
      "redCards": <int 0-2>,
      "xg": <float 0.5-3.5>,
      "corners": <int 2-10>,
      "dribbles": <int 10-40>
    },
    "away": {
      "possession": <int 30-70>,
      "shots": <int 8-20>,
      "onTarget": <int 2-10>,
      "passes": <int 300-600>,
      "passAccuracy": <float 75-95>,
      "tackles": <int 10-25>,
      "aerialDuels": <int 15-30>,
      "fouls": <int 5-20>,
      "yellowCards": <int 0-5>,
      "redCards": <int 0-2>,
      "xg": <float 0.5-3.5>,
      "corners": <int 2-10>,
      "dribbles": <int 10-40>
    }
  },
  "highlights": ["<event description>", "<event description>"]
}

Make realistic predictions based on team strengths. Ensure possession adds up to 100.
''';
  }
}
