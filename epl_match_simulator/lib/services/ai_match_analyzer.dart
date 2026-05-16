import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_prediction.dart';

class AiMatchAnalyzer {
  static const String _apiKey = String.fromEnvironment('CLAUDE_API_KEY',
      defaultValue: '');
  static const String _apiEndpoint =
      'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-6';
  static const String _apiVersion = '2024-06-01';

  static Future<String> analyzeMatch(MatchPrediction prediction) async {
    // Check if API key is configured
    if (_apiKey.isEmpty) {
      throw Exception('CLAUDE_API_KEY is not configured. Please set the environment variable.');
    }

    try {
      final prompt = _buildAnalysisPrompt(prediction);

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': _apiVersion,
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 512,
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
        final analysis = jsonResponse['content'][0]['text'] as String;
        return analysis;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static String _generateFallbackAnalysis(MatchPrediction prediction) {
    final scoreGap = (prediction.homeScore - prediction.awayScore).abs();
    final homeControl = (prediction.possession * 100).toStringAsFixed(1);
    final awayControl = (100 - double.parse(homeControl)).toStringAsFixed(1);
    final homeTeam = prediction.homeTeam;
    final awayTeam = prediction.awayTeam;

    final analyses = <String>[];

    // Match Result Analysis
    if (scoreGap == 0) {
      analyses.add('• Stalemate Result: The teams were evenly matched, with both squads demonstrating comparable quality');
    } else if (prediction.homeScore > prediction.awayScore) {
      analyses.add('• Home Superiority: ${prediction.homeTeamName} secured a decisive ${scoreGap}-goal victory through superior execution');
    } else {
      analyses.add('• Away Triumph: ${prediction.awayTeamName} displayed impressive character to secure an away victory');
    }

    // Possession and Control
    analyses.add('• Possession Dominance: ${prediction.homeTeamName} controlled $homeControl% of the ball, dictating play tempo');

    // Attacking Performance
    final totalShots = prediction.homeScore + prediction.awayScore;
    if (totalShots > 0) {
      final shotsOnTarget = totalShots + 2;
      analyses.add('• Clinical Finishing: ${totalShots} goals from ${shotsOnTarget} shots on target demonstrates efficiency');
    }

    // Tactical Dynamics
    final attackDiff = homeTeam.attackPower - awayTeam.attackPower;
    final defDiff = homeTeam.defensePower - awayTeam.defensePower;
    if (attackDiff.abs() > 5) {
      if (attackDiff > 0) {
        analyses.add('• Attacking Advantage: ${prediction.homeTeamName}\'s superior offensive firepower proved decisive');
      } else {
        analyses.add('• Defensive Challenge: ${prediction.homeTeamName} faced significant offensive pressure from ${prediction.awayTeamName}');
      }
    }

    if (defDiff.abs() > 5) {
      if (defDiff > 0) {
        analyses.add('• Defensive Solidity: ${prediction.homeTeamName} maintained a more organized defensive structure');
      } else {
        analyses.add('• Defensive Vulnerability: ${prediction.homeTeamName} struggled defensively against ${prediction.awayTeamName}\'s attacks');
      }
    }

    // Key Performers
    analyses.add('• Standout Performance: ${prediction.mom} delivered match-winning contributions with exceptional displays');

    // Goal Sequence
    if (prediction.goals.isNotEmpty) {
      final goalScorers = prediction.goals.map((g) => g.scorer).toSet().join(', ');
      analyses.add('• Goal Scorers: Crucial strikes from $goalScorers shaped the match outcome');
    }

    return analyses.join('\n');
  }

  static String _buildAnalysisPrompt(MatchPrediction prediction) {
    final homeControl = (prediction.possession * 100).toStringAsFixed(1);
    final awayControl = (100 - double.parse(homeControl)).toStringAsFixed(1);

    return '''
You are an expert football analyst. Analyze this Premier League match prediction and provide detailed tactical insights.

MATCH DETAILS:
${prediction.homeTeamName} (Home) vs ${prediction.awayTeamName} (Away)
Final Score: ${prediction.homeScore} - ${prediction.awayScore}
Possession: ${prediction.homeTeamName} ${homeControl}% | ${prediction.awayTeamName} ${awayControl}%
Man of the Match: ${prediction.mom}

HOME TEAM STATS:
- Attack Power: ${prediction.homeTeam.attackPower}
- Defense Power: ${prediction.homeTeam.defensePower}
- Ball Control: ${prediction.homeTeam.ballControl}

AWAY TEAM STATS:
- Attack Power: ${prediction.awayTeam.attackPower}
- Defense Power: ${prediction.awayTeam.defensePower}
- Ball Control: ${prediction.awayTeam.ballControl}

GOAL SEQUENCE:
${prediction.goals.isEmpty ? 'No goals scored' : prediction.goals.map((g) => '${g.minute}: ${g.scorer} (${g.team})${g.assist != null ? ' - assisted by ${g.assist}' : ''}').join('\n')}

ANALYSIS REQUIREMENTS:
Provide 5-7 detailed bullet points covering:
1. Match Flow & Tactical Performance
2. Possession and Control Analysis
3. Defensive Stability and Vulnerabilities
4. Key Attacking Moments and Clinical Finishing
5. Standout Individual Performances
6. Turning Points and Critical Moments
7. Overall Match Assessment and Contributing Factors

Be analytical, specific, and insightful. Use football terminology appropriately.
''';
  }
}
