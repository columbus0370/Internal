import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/team.dart';

class TeamDataLoader {
  static Future<List<Team>> loadTeams() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/pl_2025_26_teams.json');
      final jsonData = jsonDecode(jsonString);
      final teamsList = jsonData['teams'] as List;

      return teamsList.map((teamData) {
        final playersList = teamData['players'] as List;
        final players = playersList.map((playerData) {
          return Player(
            name: playerData['name'] as String,
            position: playerData['position'] as String,
            overallRating: playerData['overallRating'] as int,
            attackRating: playerData['attackRating'] as int,
            defenseRating: playerData['defenseRating'] as int,
            passingRating: playerData['passingRating'] as int,
          );
        }).toList();

        return Team(
          id: teamData['id'] as String,
          name: teamData['name'] as String,
          leagueRank: teamData['leagueRank'] as int,
          overallPower: teamData['overallPower'] as int,
          attackPower: teamData['attackPower'] as int,
          defensePower: teamData['defensePower'] as int,
          ballControl: teamData['ballControl'] as int,
          players: players,
          formation: teamData['formation'] as String? ?? '4-3-3',
        );
      }).toList();
    } catch (e) {
      print('Error loading teams: $e');
      return [];
    }
  }

  static Future<Team?> getTeamByName(String teamName) async {
    final teams = await loadTeams();
    try {
      return teams.firstWhere(
        (team) => team.name.toLowerCase() == teamName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
