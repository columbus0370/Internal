import 'package:flutter/material.dart';
import '../models/team.dart';
import '../services/prediction_engine.dart';
import '../utils/team_badges.dart';
import 'prediction_result_screen.dart';

class TeamSelectionScreen extends StatefulWidget {
  final List<Team> teams;
  final Function(Team, Team) onTeamsSelected;

  const TeamSelectionScreen({
    super.key,
    required this.teams,
    required this.onTeamsSelected,
  });

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  Team? homeTeam;
  Team? awayTeam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Predictor'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Home Team',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTeamDropdown(
              selectedTeam: homeTeam,
              onChanged: (team) => setState(() => homeTeam = team),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Away Team',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTeamDropdown(
              selectedTeam: awayTeam,
              onChanged: (team) => setState(() => awayTeam = team),
            ),
            const SizedBox(height: 32),
            if (homeTeam != null && awayTeam != null)
              _buildTeamComparison(homeTeam!, awayTeam!),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: homeTeam != null && awayTeam != null && homeTeam != awayTeam
                  ? () {
                      final prediction = PredictionEngine.predictMatch(homeTeam!, awayTeam!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PredictionResultScreen(prediction: prediction),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text(
                'Predict Match',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamDropdown({
    Team? selectedTeam,
    required Function(Team?) onChanged,
  }) {
    return DropdownButton<Team>(
      value: selectedTeam,
      isExpanded: true,
      hint: const Text('Choose a team'),
      items: widget.teams
          .map((team) => DropdownMenuItem(
                value: team,
                child: Row(
                  children: [
                    Text(
                      getTeamBadge(team.name),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 12),
                    Text(team.name),
                  ],
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTeamComparison(Team home, Team away) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTeamBadge(home.name),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              home.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow('Overall', home.overallPower, away.overallPower),
                      _buildStatRow('Attack', home.attackPower, away.attackPower),
                      _buildStatRow('Defense', home.defensePower, away.defensePower),
                      _buildStatRow('Ball Control', home.ballControl, away.ballControl),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTeamBadge(away.name),
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              away.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int homeStat, int awayStat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$homeStat',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '$awayStat',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
