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

  // 本番環境かどうかを判定（実行時にホスト情報から判定）
  static bool get _isProduction {
    // Flutter Web では String.fromEnvironment はコンパイル時のみ有効なので、
    // 実行時の判定にはホスト情報を使用する
    try {
      final currentUrl = Uri.base.toString();
      // localhostやIPアドレスでなければ本番環境と判定
      return !currentUrl.contains('localhost') &&
             !currentUrl.contains('127.0.0.1') &&
             !currentUrl.contains('0.0.0.0');
    } catch (e) {
      // エラー時は本番環境扱い（安全サイド）
      return true;
    }
  }

  static String get _apiUrl {
    return _isProduction ? _productionUrl : _apiBaseUrl;
  }

  static Future<Map<String, dynamic>> analyzeMatch(
    MatchPrediction prediction, {
    int matchQuarter = 0,
  }) async {
    try {
      final matchData = {
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
        'result': prediction.result,
        'goals': prediction.goals.map((g) => {
          'minute': g.minute,
          'scorer': g.scorer,
          'team': g.team,
          'assist': g.assist,
        }).toList(),
      };

      final requestBody = {
        'prediction': matchData,
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
            'model': data['model'] ?? 'unknown',
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
        'error': 'Request timeout (60s)',
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
    final narrative = '''${prediction.homeTeamName} vs ${prediction.awayTeamName}

【試合概況】
${prediction.homeTeamName}がホームでの試合に臨み、${prediction.awayTeamName}がアウェイからの挑戦。
最終スコア：${prediction.homeScore}対${prediction.awayScore}（${prediction.result}）

【前半】
試合開始から両チームが激しく競い合う。${prediction.homeTeamName}はホーム有利を活かし、ボール支配率${(prediction.possession * 100).toStringAsFixed(1)}%で試合を優位に進める。${prediction.awayTeamName}も効率的なカウンター攻撃で対抗する。

【後半】
後半に入ると、試合の流れが激化。主要な得点シーンが生まれ、試合は最後まで白熱した展開となる。

【試合評価】
${prediction.homeTeamName}の攻撃力${prediction.homeTeam.attackPower}と${prediction.awayTeamName}の守備力${prediction.awayTeam.defensePower}の対比が試合の鍵となった。''';

    return {
      'narrative': narrative,
      'narrative_segments': [
        {
          'quarter': 1,
          'minute_range': '0-15',
          'events': [
            {
              'minute': '5',
              'team': prediction.homeTeamName,
              'event_type': 'possession',
              'description': '試合開始。${prediction.homeTeamName}がボール支配で試合をリード。'
            }
          ],
          'quarter_summary': '試合開始。${prediction.homeTeamName}がホーム有利で序盤を支配。'
        },
        {
          'quarter': 2,
          'minute_range': '15-30',
          'events': [
            {
              'minute': '20',
              'team': prediction.awayTeamName,
              'event_type': 'counter',
              'description': '${prediction.awayTeamName}がカウンター攻撃で反撃を試みる。'
            }
          ],
          'quarter_summary': '両チームが競い合い、激しいテンポで試合が進む。'
        },
        {
          'quarter': 3,
          'minute_range': '45-60',
          'events': [
            {
              'minute': '50',
              'team': prediction.homeTeamName,
              'event_type': 'shot',
              'description': '${prediction.homeTeamName}が得点チャンスを迎える。'
            }
          ],
          'quarter_summary': '後半戦が始まり、試合の流れが変わる。'
        },
        {
          'quarter': 4,
          'minute_range': '75-90',
          'events': [
            {
              'minute': '80',
              'team': prediction.homeTeamName,
              'event_type': 'goal',
              'description': '決定的な得点シーン。最終的に${prediction.homeScore}対${prediction.awayScore}で終了。'
            }
          ],
          'quarter_summary': '試合終盤。${prediction.homeTeamName}が勝利を確定させる。'
        }
      ],
      'overall_summary': '${prediction.homeTeamName}が${prediction.homeScore}対${prediction.awayScore}で${prediction.result}。${prediction.mom}がマン・オブ・ザ・マッチに選ばれた。',
      'summary': '${prediction.homeTeamName}が${prediction.awayTeamName}とのマッチアップで、${prediction.homeScore}対${prediction.awayScore}で勝利。',
      'keyMoments': prediction.goals
          .map((goal) => {
            'minute': goal.minute,
            'team': goal.team,
            'event': 'Goal',
            'description': '${goal.scorer}が得点を挙げた。${goal.assist != null ? 'アシスト：${goal.assist}' : 'ダイレクト得点'}'
          })
          .toList(),
    };
  }
}
