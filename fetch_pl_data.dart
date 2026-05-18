import 'dart:convert';
import 'package:http/http.dart' as http;

// このスクリプトは、プレミアリーグ2025-26シーズンの選手データを取得します
// football-data.org APIを使用しています

Future<void> main() async {
  const apiKey = 'YOUR_API_KEY'; // football-data.org から取得してください
  const leagueCode = 'PL'; // Premier League
  const season = 2025; // 2025-26シーズン

  final url =
      'https://api.football-data.org/v4/competitions/$leagueCode/standings?season=$season';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Auth-Token': apiKey},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      // チームデータを取得
      final standings = jsonData['standings'][0]['table'] as List;

      print('プレミアリーグ2025-26シーズンのチーム情報を取得中...\n');

      // 各チームの詳細情報を取得
      for (var i = 0; i < standings.length; i++) {
        final team = standings[i];
        final teamId = team['team']['id'];
        final teamName = team['team']['name'];

        print('[$i] $teamName (ID: $teamId)');

        // チームの選手情報を取得
        await fetchTeamPlayers(teamId, teamName, apiKey);
      }
    } else {
      print('エラー: ${response.statusCode}');
      print(response.body);
    }
  } catch (e) {
    print('例外: $e');
  }
}

Future<void> fetchTeamPlayers(
    int teamId, String teamName, String apiKey) async {
  final url = 'https://api.football-data.org/v4/teams/$teamId';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'X-Auth-Token': apiKey},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final squad = jsonData['squad'] as List;

      print('  選手数: ${squad.length}');
      for (var player in squad.take(3)) {
        print('    - ${player['name']} (${player['position']})');
      }
      print('');
    }
  } catch (e) {
    print('  エラー: $e');
  }
}
