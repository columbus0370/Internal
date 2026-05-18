import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/match_prediction.dart';

class MatchAnalysisService {
  // ローカル開発用
  static const String _apiBaseUrl = 'http://localhost:3000';
  // 本番環境用
  static const String _productionUrl =
      'https://epl-match-simulator.vercel.app';
  static const Duration _timeout = Duration(seconds: 60);

  // 本番環境かどうかを判定（Vercel デプロイ時は VERCEL 環境変数が設定される）
  static bool get _isProduction {
    const isVercel = String.fromEnvironment('VERCEL', defaultValue: '');
    return isVercel.isNotEmpty;
  }

  static String get _apiUrl {
    return _isProduction ? _productionUrl : _apiBaseUrl;
  }

  static Future<Map<String, dynamic>> analyzeMatch(MatchPrediction prediction) async {
    try {
      final requestBody = {
        'prediction': {
          'homeTeamName': prediction.homeTeamName,
          'awayTeamName': prediction.awayTeamName,
          'homeScore': prediction.homeScore,
          'awayScore': prediction.awayScore,
          'homeTeam': {
            'attackPower': prediction.homeTeam.attackPower,
            'defensePower': prediction.homeTeam.defensePower,
            'ballControl': prediction.homeTeam.ballControl,
          },
          'awayTeam': {
            'attackPower': prediction.awayTeam.attackPower,
            'defensePower': prediction.awayTeam.defensePower,
            'ballControl': prediction.awayTeam.ballControl,
          },
          'possession': prediction.possession,
          'mom': prediction.mom,
          'goals': prediction.goals.map((g) => {
            'minute': g.minute,
            'player': g.player,
            'team': g.team,
          }).toList(),
        }
      };

      final response = await http
          .post(
            Uri.parse('$_apiUrl/api/analyzeMatch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'analysis': data['analysis'],
            'source': data['source'] ?? 'unknown',
          };
        } else {
          return {
            'success': false,
            'analysis': _generateFallbackAnalysis(prediction),
            'error': data['error'] ?? 'Unknown error',
          };
        }
      } else {
        return {
          'success': false,
          'analysis': _generateFallbackAnalysis(prediction),
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'analysis': _generateFallbackAnalysis(prediction),
        'error': 'Request timeout',
      };
    } catch (e) {
      return {
        'success': false,
        'analysis': _generateFallbackAnalysis(prediction),
        'error': e.toString(),
      };
    }
  }

  static Map<String, dynamic> _generateFallbackAnalysis(MatchPrediction prediction) {
    return {
      'summary': '${prediction.homeTeamName}が${prediction.awayTeamName}とのマッチアップで、試合結果${prediction.homeScore}対${prediction.awayScore}という予測です。',
      'homeTeamAnalysis': '${prediction.homeTeamName}は攻撃力${prediction.homeTeam.attackPower}、守備力${prediction.homeTeam.defensePower}を持っています。ホーム有利を活かした試合展開が期待されます。',
      'awayTeamAnalysis': '${prediction.awayTeamName}は攻撃力${prediction.awayTeam.attackPower}、守備力${prediction.awayTeam.defensePower}で対抗します。アウェイながら効率的な攻撃が重要になります。',
      'tacticalPoints': '${prediction.homeTeamName}のホーム有利とボール支配に対し、${prediction.awayTeamName}がカウンター攻撃をどう活かすかが焦点です。',
      'keyPlayers': '${prediction.mom}が試合の決定的な場面で活躍することが予想されます。',
      'possessionAnalysis': 'ボール保持率は${(prediction.possession * 100).toStringAsFixed(1)}%で、${prediction.homeTeamName}が支配的な試合展開になるでしょう。',
      'prediction': '${prediction.homeTeamName}が${prediction.homeScore}対${prediction.awayScore}で勝利する予測です。',
      'risks': '予想外の個人的なエラーや怪我による退場が試合の流れを大きく変える可能性があります。',
    };
  }
}
