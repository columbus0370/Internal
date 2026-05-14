import 'package:flutter/material.dart';
import '../models/match_prediction.dart';
import '../models/team.dart';

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
            _selectedTabIndex == 0 ? _buildStamenTab() : _buildStatsTab(),
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
        ],
      ),
    );
  }

  Widget _buildStamenTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Starting Lineup',
              style: _headerStyle,
            ),
            const SizedBox(height: 24),
            UnifiedSoccerFieldWidget(
              homeTeam: widget.prediction.homeTeam,
              awayTeam: widget.prediction.awayTeam,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Match Statistics',
              style: _headerStyle,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Possession', '${(widget.prediction.possession * 100).toStringAsFixed(1)}%',
                '${((1 - widget.prediction.possession) * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            _buildStatRow('Shots', '${widget.prediction.homeScore * 3 + 5}',
                '${widget.prediction.awayScore * 3 + 4}'),
            const SizedBox(height: 12),
            _buildStatRow('Goals', '${widget.prediction.homeScore}',
                '${widget.prediction.awayScore}'),
          ],
        ),
      ),
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
    final gk = team.players.where((p) => p.position == 'GK').first;
    final defenders = team.players.where((p) => p.position == 'DF').toList();
    final midfielders = team.players.where((p) => p.position == 'MF').toList();
    final forwards = team.players.where((p) => p.position == 'ST').toList();

    return [
      {'name': gk.name},
      {'name': defenders.isNotEmpty ? defenders[0].name : ''},
      {'name': defenders.length > 1 ? defenders[1].name : ''},
      {'name': defenders.length > 2 ? defenders[2].name : ''},
      {'name': defenders.length > 3 ? defenders[3].name : ''},
      {'name': midfielders.isNotEmpty ? midfielders[0].name : ''},
      {'name': midfielders.length > 1 ? midfielders[1].name : ''},
      {'name': midfielders.length > 2 ? midfielders[2].name : ''},
      {'name': forwards.isNotEmpty ? forwards[0].name : ''},
      {'name': forwards.length > 1 ? forwards[1].name : ''},
      {'name': forwards.length > 2 ? forwards[2].name : ''},
    ];
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

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      whiteSolidPaint,
    );

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      whiteSolidPaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.15,
      whiteSolidPaint,
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    final penaltyWidth = size.width * 0.25;
    final penaltyHeight = size.height * 0.4;

    canvas.drawRect(
      Rect.fromLTWH(0, (size.height - penaltyHeight) / 2, penaltyWidth,
          penaltyHeight),
      whiteSolidPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width - penaltyWidth, (size.height - penaltyHeight) / 2,
          penaltyWidth, penaltyHeight),
      whiteSolidPaint,
    );

    final goalWidth = size.width * 0.08;
    final goalHeight = size.height * 0.2;

    canvas.drawRect(
      Rect.fromLTWH(0, (size.height - goalHeight) / 2, goalWidth, goalHeight),
      whiteSolidPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(size.width - goalWidth, (size.height - goalHeight) / 2,
          goalWidth, goalHeight),
      whiteSolidPaint,
    );
  }

  @override
  bool shouldRepaint(SoccerFieldPainter oldDelegate) => false;
}

