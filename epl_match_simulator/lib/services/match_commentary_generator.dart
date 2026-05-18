import 'dart:math';
import '../models/match_prediction.dart';
import '../models/match_commentary.dart';
import '../models/team.dart';

class MatchCommentaryGenerator {
  static List<MatchCommentary> generateCommentary(MatchPrediction prediction) {
    final commentaries = <MatchCommentary>[];
    final random = Random();

    // 前半のシーン生成
    commentaries.addAll(_generatePeriodCommentary(
      prediction: prediction,
      period: '前半',
      startMinute: 0,
      endMinute: 45,
      random: random,
    ));

    // 後半のシーン生成
    commentaries.addAll(_generatePeriodCommentary(
      prediction: prediction,
      period: '後半',
      startMinute: 45,
      endMinute: 90,
      random: random,
    ));

    // ゴール情報を挿入
    for (final goal in prediction.goals) {
      _insertGoalCommentary(commentaries, goal, prediction);
    }

    // 時系列でソート
    commentaries.sort((a, b) {
      final periodOrder = a.period == '前半' ? 0 : 1;
      final bPeriodOrder = b.period == '前半' ? 0 : 1;
      if (periodOrder != bPeriodOrder) return periodOrder.compareTo(bPeriodOrder);
      return a.minute.compareTo(b.minute);
    });

    return commentaries;
  }

  static List<MatchCommentary> _generatePeriodCommentary({
    required MatchPrediction prediction,
    required String period,
    required int startMinute,
    required int endMinute,
    required Random random,
  }) {
    final commentaries = <MatchCommentary>[];
    final sceneCount = random.nextInt(4) + 3; // 3〜6シーン

    final homeTeamPlayers = prediction.homeTeam.players
        .where((p) => p.position != 'GK')
        .toList();
    final awayTeamPlayers = prediction.awayTeam.players
        .where((p) => p.position != 'GK')
        .toList();

    for (int i = 0; i < sceneCount; i++) {
      final minute = startMinute + random.nextInt(endMinute - startMinute - 5) + 2;
      final isHomeAttack = random.nextBool();

      final commentary = _generateScene(
        prediction: prediction,
        period: period,
        minute: minute,
        isHomeAttack: isHomeAttack,
        homeTeamPlayers: homeTeamPlayers,
        awayTeamPlayers: awayTeamPlayers,
        random: random,
      );

      if (!commentaries.any((c) => c.minute == commentary.minute && c.period == commentary.period)) {
        commentaries.add(commentary);
      }
    }

    return commentaries;
  }

  static MatchCommentary _generateScene({
    required MatchPrediction prediction,
    required String period,
    required int minute,
    required bool isHomeAttack,
    required List<dynamic> homeTeamPlayers,
    required List<dynamic> awayTeamPlayers,
    required Random random,
  }) {
    final attackingTeamPlayers = isHomeAttack ? homeTeamPlayers : awayTeamPlayers;
    final defendingTeamPlayers = isHomeAttack ? awayTeamPlayers : homeTeamPlayers;
    final attackingTeamName = isHomeAttack ? prediction.homeTeamName : prediction.awayTeamName;
    final defendingTeamName = isHomeAttack ? prediction.awayTeamName : prediction.homeTeamName;

    if (attackingTeamPlayers.isEmpty) {
      return MatchCommentary(
        minute: minute,
        period: period,
        action: 'パス',
        playerName: '選手',
        teamName: attackingTeamName,
        description: '$attackingTeamNameが攻撃を仕掛ける',
      );
    }

    final actionType = random.nextInt(100);
    final player = attackingTeamPlayers[random.nextInt(attackingTeamPlayers.length)];
    final playerName = player.name ?? '選手';
    final defender = defendingTeamPlayers.isNotEmpty
        ? defendingTeamPlayers[random.nextInt(defendingTeamPlayers.length)]
        : null;

    if (actionType < 40) {
      // ドリブル・パスプレー
      final position = _getPosition(player.position ?? 'MF');
      final side = random.nextBool() ? '右' : '左';

      if (attackingTeamPlayers.length > 1) {
        final teammate = attackingTeamPlayers.firstWhere(
          (p) => p.name != playerName,
          orElse: () => attackingTeamPlayers[random.nextInt(attackingTeamPlayers.length)]
        );
        return MatchCommentary(
          minute: minute,
          period: period,
          action: 'ドリブル',
          playerName: playerName,
          teamName: attackingTeamName,
          description: '$side サイドの$playerNameがドリブル突破をし、${teammate.name}へのクロスを放つ！',
        );
      } else {
        return MatchCommentary(
          minute: minute,
          period: period,
          action: 'ドリブル',
          playerName: playerName,
          teamName: attackingTeamName,
          description: '$side サイドの$playerNameがドリブルで前進する',
        );
      }
    } else if (actionType < 70) {
      // シュート
      return MatchCommentary(
        minute: minute,
        period: period,
        action: 'シュート',
        playerName: playerName,
        teamName: attackingTeamName,
        description: '$playerNameが素晴らしいシュートを放つ！',
      );
    } else if (actionType < 85) {
      // セーブ
      final gk = defendingTeamName == prediction.homeTeamName
          ? prediction.homeTeam.players.firstWhere(
              (p) => p.position == 'GK',
              orElse: () => Player(
                name: 'GK',
                position: 'GK',
                subPosition: 'GK',
                overallRating: 80,
                attackRating: 20,
                defenseRating: 80,
                passingRating: 80,
              )
            )
          : prediction.awayTeam.players.firstWhere(
              (p) => p.position == 'GK',
              orElse: () => Player(
                name: 'GK',
                position: 'GK',
                subPosition: 'GK',
                overallRating: 80,
                attackRating: 20,
                defenseRating: 80,
                passingRating: 80,
              )
            );

      return MatchCommentary(
        minute: minute,
        period: period,
        action: 'セーブ',
        playerName: gk.name,
        teamName: defendingTeamName,
        description: '${gk.name}がビックセーブ！',
      );
    } else {
      // ファウル
      return MatchCommentary(
        minute: minute,
        period: period,
        action: 'ファウル',
        playerName: playerName,
        teamName: attackingTeamName,
        description: '$playerNameがファウルを犯す',
      );
    }
  }

  static void _insertGoalCommentary(
    List<MatchCommentary> commentaries,
    GoalEvent goal,
    MatchPrediction prediction,
  ) {
    final minuteInt = int.tryParse(goal.minute) ?? 45;
    final period = minuteInt <= 45 ? '前半' : '後半';
    final assistText = goal.assist != null ? '(${goal.assist}からのアシスト)' : '';

    commentaries.add(
      MatchCommentary(
        minute: minuteInt,
        period: period,
        action: 'ゴール',
        playerName: goal.scorer,
        teamName: goal.team,
        description: 'ゴール！！！${goal.team}の${goal.scorer}が得点$assistText',
      ),
    );
  }

  static String _getPosition(String position) {
    switch (position) {
      case 'DF':
        return 'ディフェンダー';
      case 'MF':
        return 'ミッドフィルダー';
      case 'ST':
        return 'ストライカー';
      default:
        return '選手';
    }
  }
}
