import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_prediction.dart';

class AiMatchAnalyzer {
  static const String _apiKey = String.fromEnvironment('CLAUDE_API_KEY',
      defaultValue: '');
  static const String _apiEndpoint =
      'https://api.anthropic.com/v1/messages';

  static Future<String> analyzeMatch(MatchPrediction prediction) async {
    if (_apiKey.isEmpty) {
      return _generateFallbackAnalysis(prediction);
    }

    try {
      final prompt = _buildAnalysisPrompt(prediction);

      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': 'claude-opus-4-1',
          'max_tokens': 500,
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
        return _generateFallbackAnalysis(prediction);
      }
    } catch (e) {
      return _generateFallbackAnalysis(prediction);
    }
  }

  static String _generateFallbackAnalysis(MatchPrediction prediction) {
    final scoreGap = (prediction.homeScore - prediction.awayScore).abs();
    final homeControl = (prediction.possession * 100).toStringAsFixed(1);
    final awayControl = ((1 - prediction.possession) * 100).toStringAsFixed(1);

    final analyses = <String>[];

    // スコア分析
    if (scoreGap == 0) {
      analyses.add('• Balanced Match: Both teams showed equal strength in this competitive fixture');
    } else if (prediction.homeScore > prediction.awayScore) {
      analyses.add('• Home Advantage: ${prediction.homeTeamName} dominated with a ${scoreGap}-goal margin');
    } else {
      analyses.add('• Away Victory: ${prediction.awayTeamName} impressed with an away win');
    }

    // ポゼッション分析
    analyses.add('• Ball Control: ${prediction.homeTeamName} controlled $homeControl% of possession');

    // ゴール分析
    if (prediction.goals.isNotEmpty) {
      analyses.add('• Goal Scorers: ${prediction.goals.take(3).map((g) => g.scorer).join(', ')} led the scoring');
    }

    // MOM分析
    analyses.add('• Player of the Match: ${prediction.mom} delivered a standout performance');

    return analyses.join('\n');
  }

  static String _buildAnalysisPrompt(MatchPrediction prediction) {
    return '''
Analyze this football match prediction and provide concise match insights in 3-4 bullet points:

${prediction.homeTeamName} vs ${prediction.awayTeamName}
Score: ${prediction.homeScore} - ${prediction.awayScore}
Result: ${prediction.result}
Possession: ${(prediction.possession * 100).toStringAsFixed(1)}%
Man of the Match: ${prediction.mom}

Goals scored:
${prediction.goals.isEmpty ? 'No goals' : prediction.goals.map((g) => '- ${g.minute}: ${g.scorer} (${g.team})${g.assist != null ? ' assisted by ${g.assist}' : ''}').join('\n')}

Provide tactical analysis, key moments, and standout performances in bullet point format. Keep it brief and insightful.
''';
  }
}
