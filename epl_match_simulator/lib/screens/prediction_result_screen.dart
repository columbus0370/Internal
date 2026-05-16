import 'package:flutter/material.dart';
import '../models/match_prediction.dart';
import '../models/team.dart';
import '../models/match_commentary.dart';
import '../models/match_stats.dart';
import '../services/ai_match_analyzer.dart';
import '../services/match_commentary_generator.dart';
import '../services/match_stats_generator.dart';

class PredictionResultScreen extends StatefulWidget {
  final MatchPrediction prediction;

  const PredictionResultScreen({
    super.key,
    required this.prediction,
  });

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  int _selectedTabIndex = 0;

  static const _scoreTextStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  );
  static const _headerStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  static const _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  static const _scorerStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  static const _boldPurpleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.deepPurple,
  );
  static const _assistStyle = TextStyle(
    fontSize: 11,
    color: Color(0xFF9E9E9E),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Prediction'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScoreCard(),
            const SizedBox(height: 24),
            if (widget.prediction.goals.isNotEmpty) ...[
              _buildTimeline(),
              const SizedBox(height: 24),
            ],
            _buildMOMCard(),
            const SizedBox(height: 24),
            _buildTabBar(),
            const SizedBox(height: 16),
            _selectedTabIndex == 0
                ? _buildStamenTab()
                : _selectedTabIndex == 1
                    ? _buildStatsTab()
                    : _buildAiAnalysisTab(),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Predict Another Match',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: _selectedTabIndex == 0
                      ? Border(
                          bottom: BorderSide(
                            color: Colors.deepPurple,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Text(
                  'Stamen',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedTabIndex == 0
                        ? Colors.deepPurple
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: _selectedTabIndex == 1
                      ? Border(
                          bottom: BorderSide(
                            color: Colors.deepPurple,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Text(
                  'Stats',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedTabIndex == 1
                        ? Colors.deepPurple
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: _selectedTabIndex == 2
                      ? Border(
                          bottom: BorderSide(
                            color: Colors.deepPurple,
                            width: 3,
                          ),
                        )
                      : null,
                ),
                child: Text(
                  'AI Analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedTabIndex == 2
                        ? Colors.deepPurple
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStamenTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Text(
              'Starting Lineup',
              style: _headerStyle,
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 50 / 150,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return RepaintBoundary(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: CustomPaint(
                        painter: SoccerFieldPainter(),
                        child: Stack(
                          children: [
                            ..._buildAwayPlayerPositionsHalf(constraints),
                            ..._buildHomePlayerPositionsHalf(constraints),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.prediction.awayTeam.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.prediction.homeTeam.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTeamRoster(widget.prediction.awayTeam, Colors.orange),
            const SizedBox(height: 24),
            _buildTeamRoster(widget.prediction.homeTeam, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRoster(Team team, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          team.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: team.players.map((player) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    player.position,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Widget> _buildAwayPlayerPositionsHalf(BoxConstraints constraints) {
    final awayTeam = widget.prediction.awayTeam;
    final players = _getFormationPlayers(awayTeam);
    final positions = _getAwayHalfPositions();
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    return List.generate(players.length, (index) {
      if (index >= positions.length) return const SizedBox.shrink();
      final pos = positions[index];
      final player = players[index];

      final pixelX = (pos['x'] as double) * width;
      final pixelY = (pos['y'] as double) * height;

      return Positioned(
        left: pixelX - 25,
        top: pixelY - 25,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  player['name']!.split(' ').last,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildHomePlayerPositionsHalf(BoxConstraints constraints) {
    final homeTeam = widget.prediction.homeTeam;
    final players = _getFormationPlayers(homeTeam);
    final positions = _getHomeHalfPositions();
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    return List.generate(players.length, (index) {
      if (index >= positions.length) return const SizedBox.shrink();
      final pos = positions[index];
      final player = players[index];

      final pixelX = (pos['x'] as double) * width;
      final pixelY = (pos['y'] as double) * height;

      return Positioned(
        left: pixelX - 25,
        top: pixelY - 25,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  player['name']!.split(' ').last,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Map<String, String>> _getFormationPlayers(Team team) {
    final gk = team.players.where((p) => p.position == 'GK').toList();
    final defenders = team.players.where((p) => p.position == 'DF').toList();
    final midfielders = team.players.where((p) => p.position == 'MF').toList();
    final forwards = team.players.where((p) => p.position == 'FW').toList();

    final players = <Map<String, String>>[];

    if (gk.isNotEmpty) players.add({'name': gk[0].name});
    for (int i = 0; i < 4 && i < defenders.length; i++) {
      players.add({'name': defenders[i].name});
    }
    for (int i = 0; i < 3 && i < midfielders.length; i++) {
      players.add({'name': midfielders[i].name});
    }
    for (int i = 0; i < 3 && i < forwards.length; i++) {
      players.add({'name': forwards[i].name});
    }

    return players;
  }

  List<Map<String, double>> _getHomeHalfPositions() {
    return [
      {'x': 0.5, 'y': 0.9},
      {'x': 0.2, 'y': 0.78},
      {'x': 0.35, 'y': 0.78},
      {'x': 0.65, 'y': 0.78},
      {'x': 0.8, 'y': 0.78},
      {'x': 0.2, 'y': 0.68},
      {'x': 0.5, 'y': 0.68},
      {'x': 0.8, 'y': 0.68},
      {'x': 0.25, 'y': 0.55},
      {'x': 0.5, 'y': 0.51},
      {'x': 0.75, 'y': 0.55},
    ];
  }

  List<Map<String, double>> _getAwayHalfPositions() {
    return [
      {'x': 0.5, 'y': 0.1},
      {'x': 0.2, 'y': 0.22},
      {'x': 0.35, 'y': 0.22},
      {'x': 0.65, 'y': 0.22},
      {'x': 0.8, 'y': 0.22},
      {'x': 0.2, 'y': 0.32},
      {'x': 0.5, 'y': 0.32},
      {'x': 0.8, 'y': 0.32},
      {'x': 0.25, 'y': 0.48},
      {'x': 0.5, 'y': 0.38},
      {'x': 0.75, 'y': 0.48},
    ];
  }

  Widget _buildStatsTab() {
    final stats = MatchStatsGenerator.generate(widget.prediction);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Text('Match Statistics', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Team name headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.prediction.homeTeamName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 60),
                Expanded(
                  child: Text(
                    widget.prediction.awayTeamName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildStatSection('⚽ Attack', [
              _buildStatBarRow('Goals', stats.homeGoals.toString(), stats.awayGoals.toString(), stats.homeGoals.toDouble(), stats.awayGoals.toDouble()),
              _buildStatBarRow('Shots', stats.homeShots.toString(), stats.awayShots.toString(), stats.homeShots.toDouble(), stats.awayShots.toDouble()),
              _buildStatBarRow('On Target', stats.homeShotsOnTarget.toString(), stats.awayShotsOnTarget.toString(), stats.homeShotsOnTarget.toDouble(), stats.awayShotsOnTarget.toDouble()),
              _buildStatBarRow('xG', stats.homeXG.toStringAsFixed(2), stats.awayXG.toStringAsFixed(2), stats.homeXG, stats.awayXG),
              _buildStatBarRow('Dribbles', stats.homeDribbles.toString(), stats.awayDribbles.toString(), stats.homeDribbles.toDouble(), stats.awayDribbles.toDouble()),
              _buildStatBarRow('Corners', stats.homeCorners.toString(), stats.awayCorners.toString(), stats.homeCorners.toDouble(), stats.awayCorners.toDouble()),
            ]),

            const SizedBox(height: 12),

            _buildStatSection('🎯 Possession & Passing', [
              _buildStatBarRow('Possession', '${stats.homePossession.toStringAsFixed(1)}%', '${stats.awayPossession.toStringAsFixed(1)}%', stats.homePossession, stats.awayPossession),
              _buildStatBarRow('Passes', stats.homePasses.toString(), stats.awayPasses.toString(), stats.homePasses.toDouble(), stats.awayPasses.toDouble()),
              _buildStatBarRow('Pass Accuracy', '${stats.homePassAccuracy.toStringAsFixed(1)}%', '${stats.awayPassAccuracy.toStringAsFixed(1)}%', stats.homePassAccuracy, stats.awayPassAccuracy),
            ]),

            const SizedBox(height: 12),

            _buildStatSection('🛡️ Defence', [
              _buildStatBarRow('Tackles', stats.homeTackles.toString(), stats.awayTackles.toString(), stats.homeTackles.toDouble(), stats.awayTackles.toDouble()),
              _buildStatBarRow('Aerial Duels', stats.homeAerialDuels.toString(), stats.awayAerialDuels.toString(), stats.homeAerialDuels.toDouble(), stats.awayAerialDuels.toDouble()),
              _buildStatBarRow('Fouls', stats.homeFouls.toString(), stats.awayFouls.toString(), stats.homeFouls.toDouble(), stats.awayFouls.toDouble()),
            ]),

            const SizedBox(height: 12),

            _buildStatSection('🟨 Discipline', [
              _buildStatBarRow('Yellow Cards', stats.homeYellowCards.toString(), stats.awayYellowCards.toString(), stats.homeYellowCards.toDouble(), stats.awayYellowCards.toDouble()),
              _buildStatBarRow('Red Cards', stats.homeRedCards.toString(), stats.awayRedCards.toString(), stats.homeRedCards.toDouble(), stats.awayRedCards.toDouble()),
            ]),

            const SizedBox(height: 12),

            _buildRatingSection(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        const SizedBox(height: 8),
        ...rows,
      ],
    );
  }

  Widget _buildStatBarRow(String label, String homeVal, String awayVal, double homeNum, double awayNum) {
    final total = homeNum + awayNum;
    final homeRatio = total > 0 ? homeNum / total : 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(homeVal, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              Text(awayVal, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Row(
              children: [
                Expanded(
                  flex: (homeRatio * 100).round().clamp(1, 99),
                  child: Container(height: 5, color: Colors.blue),
                ),
                Expanded(
                  flex: ((1 - homeRatio) * 100).round().clamp(1, 99),
                  child: Container(height: 5, color: Colors.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(MatchStats stats) {
    final home = widget.prediction.homeTeam;
    final away = widget.prediction.awayTeam;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 Team Ratings', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildRatingBar('ATK', home.attackPower, Colors.blue)),
              const SizedBox(width: 6),
              Expanded(child: _buildRatingBar('ATK', away.attackPower, Colors.orange)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildRatingBar('DEF', home.defensePower, Colors.blue)),
              const SizedBox(width: 6),
              Expanded(child: _buildRatingBar('DEF', away.defensePower, Colors.orange)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: _buildRatingBar('CTL', home.ballControl, Colors.blue)),
              const SizedBox(width: 6),
              Expanded(child: _buildRatingBar('CTL', away.ballControl, Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / 100.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 24,
          child: Text('$value', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String homeValue, String awayValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(homeValue, style: _boldPurpleStyle),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(awayValue, style: _boldPurpleStyle),
      ],
    );
  }

  Widget _buildAiAnalysisTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            const Text(
              '試合実況 - Match Commentary',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._buildCommentaryList(),
            const SizedBox(height: 18),
            const Divider(thickness: 1.5),
            const SizedBox(height: 12),
            const Text(
              'AI Tactical Analysis',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<String>(
              future: AiMatchAnalyzer.analyzeMatch(widget.prediction),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text(
                    'Loading analysis...',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  );
                }

                final analysis = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.deepPurple.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    analysis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCommentaryList() {
    final commentaries = MatchCommentaryGenerator.generateCommentary(widget.prediction);

    return commentaries.map((commentary) {
      final color = commentary.teamName == widget.prediction.homeTeamName
          ? Colors.blue
          : Colors.orange;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color,
                width: 3,
              ),
            ),
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      commentary.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      commentary.action,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                commentary.description,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.prediction.homeTeamName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.prediction.homeScore}',
                        style: _scoreTextStyle,
                      ),
                    ],
                  ),
                ),
                const Text(
                  '-',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.prediction.awayTeamName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.prediction.awayScore}',
                        style: _scoreTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.prediction.result,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMOMCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Man of the Match',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.prediction.mom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Timeline',
              style: _headerStyle,
            ),
            const SizedBox(height: 16),
            ...widget.prediction.goals.map((goal) {
              final isHomeGoal = goal.team == widget.prediction.homeTeamName;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isHomeGoal
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isHomeGoal ? Colors.blue : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isHomeGoal ? Colors.blue : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '⚽',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  goal.minute,
                                  style: _labelStyle,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal.scorer,
                                        style: _scorerStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (goal.assist != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          goal.assist!,
                                          style: _assistStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class UnifiedSoccerFieldWidget extends StatelessWidget {
  final Team homeTeam;
  final Team awayTeam;

  const UnifiedSoccerFieldWidget({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
  });

  List<Map<String, String>> _getFormationPlayers(Team team) {
    final gk = team.players.where((p) => p.position == 'GK').toList();
    final defenders = team.players.where((p) => p.position == 'DF').toList();
    final midfielders = team.players.where((p) => p.position == 'MF').toList();
    final forwards = team.players.where((p) => p.position == 'FW').toList();

    final players = <Map<String, String>>[];

    if (gk.isNotEmpty) players.add({'name': gk[0].name});
    for (int i = 0; i < 4 && i < defenders.length; i++) {
      players.add({'name': defenders[i].name});
    }
    for (int i = 0; i < 3 && i < midfielders.length; i++) {
      players.add({'name': midfielders[i].name});
    }
    for (int i = 0; i < 3 && i < forwards.length; i++) {
      players.add({'name': forwards[i].name});
    }

    return players;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          homeTeam.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 105 / 136,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: CustomPaint(
                  painter: SoccerFieldPainter(),
                  child: Stack(
                    children: [
                      ..._buildPlayerPositions(constraints, homeTeam, true),
                      ..._buildPlayerPositions(constraints, awayTeam, false),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          awayTeam.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPlayerPositions(
      BoxConstraints constraints, Team team, bool isHome) {
    final players = _getFormationPlayers(team);
    final positions = _getPositions(isHome);
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    return List.generate(players.length, (index) {
      if (index >= positions.length) return const SizedBox.shrink();
      final pos = positions[index];
      final player = players[index];

      final pixelX = (pos['x'] as double) * width;
      final pixelY = (pos['y'] as double) * height;

      return Positioned(
        left: pixelX - 25,
        top: pixelY - 25,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isHome ? Colors.blue : Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Center(
              child: Text(
                player['name']!.split(' ').last,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Map<String, double>> _getPositions(bool isHome) {
    if (isHome) {
      return [
        {'x': 0.5, 'y': 0.9},
        {'x': 0.2, 'y': 0.78},
        {'x': 0.2, 'y': 0.6},
        {'x': 0.2, 'y': 0.42},
        {'x': 0.2, 'y': 0.24},
        {'x': 0.35, 'y': 0.72},
        {'x': 0.35, 'y': 0.5},
        {'x': 0.35, 'y': 0.28},
        {'x': 0.65, 'y': 0.68},
        {'x': 0.65, 'y': 0.5},
        {'x': 0.65, 'y': 0.32},
      ];
    } else {
      return [
        {'x': 0.5, 'y': 0.1},
        {'x': 0.2, 'y': 0.22},
        {'x': 0.2, 'y': 0.4},
        {'x': 0.2, 'y': 0.58},
        {'x': 0.2, 'y': 0.76},
        {'x': 0.35, 'y': 0.28},
        {'x': 0.35, 'y': 0.5},
        {'x': 0.35, 'y': 0.72},
        {'x': 0.65, 'y': 0.32},
        {'x': 0.65, 'y': 0.5},
        {'x': 0.65, 'y': 0.68},
      ];
    }
  }
}

class SoccerFieldWidget extends StatelessWidget {
  final String teamName;
  final bool isHome;

  const SoccerFieldWidget({
    super.key,
    required this.teamName,
    required this.isHome,
  });

  List<String> _getFormationPlayers() {
    return [
      'GK',
      'LB',
      'CB',
      'CB',
      'RB',
      'LM',
      'CM',
      'RM',
      'LW',
      'ST',
      'RW',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          teamName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 105 / 68,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: CustomPaint(
                  painter: SoccerFieldPainter(),
                  child: Stack(
                    children: _buildPlayerPositions(constraints),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPlayerPositions(BoxConstraints constraints) {
    final players = _getFormationPlayers();
    final positions = _getPositions();
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    return List.generate(players.length, (index) {
      if (index >= positions.length) return const SizedBox.shrink();
      final pos = positions[index];

      final pixelX = (pos['x'] as double) * width;
      final pixelY = (pos['y'] as double) * height;

      return Positioned(
        left: pixelX - 25,
        top: pixelY - 25,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isHome ? Colors.blue : Colors.orange,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  players[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  List<Map<String, double>> _getPositions() {
    return [
      {'x': 0.1, 'y': 0.5},
      {'x': 0.2, 'y': 0.15},
      {'x': 0.2, 'y': 0.5},
      {'x': 0.2, 'y': 0.85},
      {'x': 0.2, 'y': 0.85},
      {'x': 0.35, 'y': 0.2},
      {'x': 0.35, 'y': 0.5},
      {'x': 0.35, 'y': 0.8},
      {'x': 0.6, 'y': 0.25},
      {'x': 0.6, 'y': 0.5},
      {'x': 0.6, 'y': 0.75},
    ];
  }
}

class SoccerFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final whiteSolidPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Field border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      whiteSolidPaint,
    );

    // Center line (vertical for portrait orientation)
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      whiteSolidPaint,
    );

    // Halfway line (horizontal)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      whiteSolidPaint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.15,
      whiteSolidPaint,
    );

    // Center spot
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Penalty areas (top and bottom for portrait)
    final penaltyWidth = size.width * 0.4;
    final penaltyHeight = size.height * 0.25;

    // Top penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyWidth) / 2,
        0,
        penaltyWidth,
        penaltyHeight,
      ),
      whiteSolidPaint,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyWidth) / 2,
        size.height - penaltyHeight,
        penaltyWidth,
        penaltyHeight,
      ),
      whiteSolidPaint,
    );

    // Goal areas (top and bottom for portrait)
    final goalWidth = size.width * 0.2;
    final goalHeight = size.height * 0.08;

    // Top goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth) / 2,
        0,
        goalWidth,
        goalHeight,
      ),
      whiteSolidPaint,
    );

    // Bottom goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth) / 2,
        size.height - goalHeight,
        goalWidth,
        goalHeight,
      ),
      whiteSolidPaint,
    );
  }

  @override
  bool shouldRepaint(SoccerFieldPainter oldDelegate) => false;
}

