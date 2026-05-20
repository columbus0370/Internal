import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/match_prediction.dart';

class MatchAnalysisService {
  static const String _apiEndpoint = '/api/analyzeMatch';
  static const Duration _timeout = Duration(seconds: 60);

  // API status tracking
  static bool _isUsingApiInLastCall = false;

  static String get apiStatus => _isUsingApiInLastCall ? 'API' : 'Fallback';

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
            Uri.parse(_apiEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _isUsingApiInLastCall = true;
          return {
            'success': true,
            'analysis': data['analysis'],
            'model': data['model'] ?? 'unknown',
          };
        } else {
          _isUsingApiInLastCall = false;
          return {
            'success': false,
            'analysis': _generateFallbackAnalysis(prediction),
            'error': data['error'] ?? 'Unknown error',
          };
        }
      } else {
        _isUsingApiInLastCall = false;
        return {
          'success': false,
          'analysis': _generateFallbackAnalysis(prediction),
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } on TimeoutException {
      _isUsingApiInLastCall = false;
      return {
        'success': false,
        'analysis': _generateFallbackAnalysis(prediction),
        'error': 'Request timeout (60s)',
      };
    } catch (e) {
      _isUsingApiInLastCall = false;
      return {
        'success': false,
        'analysis': _generateFallbackAnalysis(prediction),
        'error': e.toString(),
      };
    }
  }

  static Map<String, dynamic> _generateFallbackAnalysis(MatchPrediction prediction) {
    final homeTeamName = prediction.homeTeamName;
    final awayTeamName = prediction.awayTeamName;
    final possession = prediction.possession;

    // Map goals to quarters (0-15, 15-30, 45-60, 75-90)
    Map<int, List<Map<String, dynamic>>> goalsByQuarter = {};
    for (var goal in (prediction.goals ?? [])) {
      final minute = int.tryParse(goal.minute.toString()) ?? 0;
      late int quarter;
      if (minute < 15) {
        quarter = 1; // 0-15
      } else if (minute < 30) {
        quarter = 2; // 15-30
      } else if (minute < 45) {
        quarter = 2; // 30-45: still Q2 (late first half)
      } else if (minute < 60) {
        quarter = 3; // 45-60
      } else {
        quarter = 4; // 60-90
      }

      goalsByQuarter.putIfAbsent(quarter, () => []);
      goalsByQuarter[quarter]!.add({
        'team': goal.team,
        'minute': minute,
        'scorer': goal.scorer,
      });
    }

    final narrative = '''${homeTeamName} vs ${awayTeamName}

【試合概況】
${homeTeamName}がホームでの試合に臨み、${awayTeamName}がアウェイからの挑戦。
最終スコア：${prediction.homeScore}対${prediction.awayScore}（${prediction.result}）

【前半】
試合開始から両チームが激しく競い合う。${homeTeamName}はホーム有利を活かし、ボール支配率${(possession * 100).toStringAsFixed(1)}%で試合を優位に進める。${awayTeamName}も効率的なカウンター攻撃で対抗する。

【後半】
後半に入ると、試合の流れが激化。主要な得点シーンが生まれ、試合は最後まで白熱した展開となる。

【試合評価】
${homeTeamName}の攻撃力${prediction.homeTeam.attackPower}と${awayTeamName}の守備力${prediction.awayTeam.defensePower}の対比が試合の鍵となった。''';

    // Generate narrative segments with quarter-specific narratives
    final List<Map<String, dynamic>> narrativeSegments = [];
    for (int quarterNum = 1; quarterNum <= 4; quarterNum++) {
      final cumulativeHomeGoals =
          _calculateCumulativeGoals(goalsByQuarter, quarterNum, homeTeamName);
      final cumulativeAwayGoals =
          _calculateCumulativeGoals(goalsByQuarter, quarterNum, awayTeamName);

      final quarter = {
        'quarter': quarterNum,
        'minute_range': _getQuarterMinuteRange(quarterNum),
        'quarter_score': '$cumulativeHomeGoals-$cumulativeAwayGoals',
        'narrative': _generateQuarterNarrative(
          quarterNum,
          homeTeamName,
          awayTeamName,
          cumulativeHomeGoals,
          cumulativeAwayGoals,
          prediction.homeTeam,
          prediction.awayTeam,
          possession,
        ),
        'events': _generateQuarterEvents(
          quarterNum,
          homeTeamName,
          awayTeamName,
          goalsByQuarter,
        ),
        'quarter_summary': _generateQuarterSummary(quarterNum, homeTeamName, awayTeamName, cumulativeHomeGoals, cumulativeAwayGoals),
      };
      narrativeSegments.add(quarter);
    }

    return {
      'narrative': narrative,
      'narrative_segments': narrativeSegments,
      'overall_summary': '${homeTeamName}が${prediction.homeScore}対${prediction.awayScore}で${prediction.result}。${prediction.mom}がマン・オブ・ザ・マッチに選ばれた。',
      'summary': '${homeTeamName}が${awayTeamName}とのマッチアップで、${prediction.homeScore}対${prediction.awayScore}で勝利。',
      'keyMoments': prediction.goals
          .map((goal) => {
            'minute': goal.minute,
            'team': goal.team,
            'event': 'Goal',
            'description':
                '${goal.scorer}が得点を挙げた。${goal.assist != null ? 'アシスト：${goal.assist}' : 'ダイレクト得点'}'
          })
          .toList(),
      'key_moments': prediction.goals
          .map((goal) => {
            'minute': goal.minute,
            'team': goal.team,
            'event': 'ゴール',
            'description':
                '${goal.scorer}が得点を挙げた。${goal.assist != null ? 'アシスト：${goal.assist}' : 'ダイレクト得点'}'
          })
          .toList(),
    };
  }

  static String _getQuarterMinuteRange(int quarterNum) {
    return switch (quarterNum) {
      1 => '0-15',
      2 => '15-45',
      3 => '45-60',
      4 => '60-90',
      _ => '0-90',
    };
  }

  static int _calculateCumulativeGoals(
    Map<int, List<Map<String, dynamic>>> goalsByQuarter,
    int upToQuarter,
    String teamName,
  ) {
    int total = 0;
    for (int q = 1; q <= upToQuarter; q++) {
      final goals = goalsByQuarter[q] ?? [];
      total += goals.where((g) => g['team'] == teamName).length;
    }
    return total;
  }

  static String _generateQuarterNarrative(
    int quarterNum,
    String homeTeamName,
    String awayTeamName,
    int homeGoals,
    int awayGoals,
    dynamic homeTeam,
    dynamic awayTeam,
    double possession,
  ) {
    final isHomeAttacking = possession > 0.55;
    final scoreLine = homeGoals > awayGoals
        ? "リード"
        : awayGoals > homeGoals
            ? "ビハインド"
            : "同点";

    String narrative = '';

    if (quarterNum == 1) {
      narrative =
          '【第1クォーター】キックオフ。${homeTeamName}${isHomeAttacking ? 'が積極的に' : 'は守備的に'}試合を開始。';
      narrative +=
          'ボール保持率${(possession * 100).toStringAsFixed(0)}%で${isHomeAttacking ? 'ホーム側が試合をコントロール' : 'アウェイ側がペースを握る'}。';
      narrative +=
          '${homeTeamName}${homeGoals > 0 ? 'が先制に成功し' : 'は得点機を迎えるも'}、$homeGoals-$awayGoalsで前半15分を終える。';
    } else if (quarterNum == 2) {
      narrative =
          '【第2クォーター】${homeTeamName}は${homeGoals > awayGoals ? '優位' : '巻き返しを図る'}中。';
      narrative +=
          '${awayTeamName}の攻撃力が活躍、サイドを経由した攻撃で得点機を創出。';
      narrative +=
          '後半に向けて$homeGoals-$awayGoalsの${scoreLine}の状況で前半を終える。';
    } else if (quarterNum == 3) {
      narrative =
          '【第3クォーター】後半開始。${homeTeamName}は前半の作戦を継続、守備力で${awayTeamName}の攻撃を封じる。';
      narrative +=
          '${homeGoals == awayGoals ? '同点状況が続く中、' : ''}得点を巡る激しい攻防が繰り広げられる。';
      narrative += '第3クォーター終盤に$homeGoals-$awayGoalsの状況に。';
    } else {
      narrative =
          '【第4クォーター】終盤の戦い。${homeTeamName}は${homeGoals > awayGoals ? '勝利を目指して' : '追いすがり'}、最後のスパート。';
      narrative +=
          '${awayTeamName}も全力で${homeGoals > awayGoals ? '同点を目指す' : 'リードを奪い取ろう'}。';
      narrative +=
          '最終的に$homeGoals-$awayGoalsで試合終了。試合全体を通じ、両チームの全力の戦いが展開された。';
    }

    return narrative.length > 600 ? narrative.substring(0, 600) : narrative;
  }

  static List<Map<String, dynamic>> _generateQuarterEvents(
    int quarterNum,
    String homeTeamName,
    String awayTeamName,
    Map<int, List<Map<String, dynamic>>> goalsByQuarter,
  ) {
    final quarterGoals = goalsByQuarter[quarterNum] ?? [];
    final events = <Map<String, dynamic>>[];

    for (var goal in quarterGoals) {
      events.add({
        'minute': goal['minute'].toString(),
        'team': goal['team'],
        'event': 'ゴール',
        'event_type': 'goal',
        'description': '${goal['scorer']}が得点を挙げた。',
      });
    }

    // Add default event if no goals in quarter
    if (events.isEmpty) {
      final defaultTeam = quarterNum.isEven ? awayTeamName : homeTeamName;
      final minuteStart = (quarterNum - 1) * 15 + 5;
      events.add({
        'minute': minuteStart.toString(),
        'team': defaultTeam,
        'event': 'ボール保持',
        'event_type': 'possession',
        'description': '試合の流れが続く。',
      });
    }

    return events;
  }

  static String _generateQuarterSummary(
    int quarterNum,
    String homeTeamName,
    String awayTeamName,
    int homeGoals,
    int awayGoals,
  ) {
    if (quarterNum == 1) {
      return '試合開始。${homeTeamName}がホーム有利で序盤を支配。';
    } else if (quarterNum == 2) {
      return '両チームが競い合い、激しいテンポで試合が進む。';
    } else if (quarterNum == 3) {
      return '後半戦が始まり、試合の流れが変わる。';
    } else {
      return '試合終盤。${homeGoals > awayGoals ? homeTeamName : awayTeamName}が勝利を確定させる。';
    }
  }
}
