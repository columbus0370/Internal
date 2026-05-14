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
      return 'AI API key not configured. Please set the CLAUDE_API_KEY environment variable.';
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
        return 'Failed to generate analysis. Status: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error analyzing match: $e';
    }
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
