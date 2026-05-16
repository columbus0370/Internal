import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/team.dart';

class TeamCacheManager {
  static const String _cacheKeyPrefix = 'team_cache_';
  static const String _cacheTimestampPrefix = 'team_cache_timestamp_';

  static Future<void> cacheTeam(Team team) async {
    final prefs = await SharedPreferences.getInstance();
    final teamJson = jsonEncode({
      'id': team.id,
      'name': team.name,
      'leagueRank': team.leagueRank,
      'overallPower': team.overallPower,
      'attackPower': team.attackPower,
      'defensePower': team.defensePower,
      'ballControl': team.ballControl,
      'formation': team.formation,
      'players': team.players.map((p) => {
        'name': p.name,
        'position': p.position,
        'overallRating': p.overallRating,
        'attackRating': p.attackRating,
        'defenseRating': p.defenseRating,
        'passingRating': p.passingRating,
      }).toList(),
    });

    await prefs.setString(_cacheKeyPrefix + team.id, teamJson);
    await prefs.setInt(_cacheTimestampPrefix + team.id, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<Team?> getTeamFromCache(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(_cacheKeyPrefix + teamId);

    if (cachedJson == null) {
      return null;
    }

    try {
      final teamData = jsonDecode(cachedJson) as Map<String, dynamic>;
      final players = (teamData['players'] as List<dynamic>).map((p) {
        return Player(
          name: p['name'],
          position: p['position'],
          overallRating: p['overallRating'],
          attackRating: p['attackRating'],
          defenseRating: p['defenseRating'],
          passingRating: p['passingRating'],
        );
      }).toList();

      return Team(
        id: teamData['id'],
        name: teamData['name'],
        leagueRank: teamData['leagueRank'],
        overallPower: teamData['overallPower'],
        attackPower: teamData['attackPower'],
        defensePower: teamData['defensePower'],
        ballControl: teamData['ballControl'],
        players: players,
        formation: teamData['formation'] ?? '4-3-3',
      );
    } catch (e) {
      return null;
    }
  }

  static Future<bool> isCached(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_cacheKeyPrefix + teamId);
  }

  static Future<void> clearTeamCache(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKeyPrefix + teamId);
    await prefs.remove(_cacheTimestampPrefix + teamId);
  }

  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cacheKeyPrefix) || key.startsWith(_cacheTimestampPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
