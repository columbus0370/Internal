import 'package:flutter/material.dart';
import 'dart:async';
import '../models/match_prediction.dart';
import '../models/team.dart';
import '../models/match_stats.dart';
import '../services/match_stats_generator.dart';
import '../services/match_analysis_service.dart';
import '../services/preference_service.dart';
import 'player_detail_screen.dart';
import 'match_simulation_screen.dart';

class PredictionResultScreen extends StatefulWidget {
  final MatchPrediction prediction;
  final int? initialTabIndex;

  const PredictionResultScreen({
    super.key,
    required this.prediction,
    this.initialTabIndex,
  });

  @override
  State<PredictionResultScreen> createState() => _PredictionResultScreenState();
}

class _PredictionResultScreenState extends State<PredictionResultScreen> {
  int _selectedTabIndex = 0;
  late Future<Map<String, dynamic>> _analysisResult;
  late StreamController<bool> _simulationStartSignal;

  @override
  void initState() {
    super.initState();
    _simulationStartSignal = StreamController<bool>.broadcast();
    _saveTeamSelection();
    _analysisResult = MatchAnalysisService.analyzeMatch(widget.prediction);
    _selectedTabIndex = widget.initialTabIndex ?? 0;

    print('PredictionResultScreen: Initializing with initialTabIndex=$_selectedTabIndex');

    // Schedule initial tab switch with adequate delay for StreamBuilder rebuild
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        print('PredictionResultScreen: Switching to Simulation tab (index 3)');
        setState(() => _selectedTabIndex = 3); // Simulation tab
      }
    });

    // Send start signal after additional delay to ensure widget is fully initialized
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_simulationStartSignal.isClosed) {
        print('PredictionResultScreen: Sending simulation start signal');
        _simulationStartSignal.add(true); // Start signal
      }
    });
  }

  Future<void> _saveTeamSelection() async {
    await PreferenceService.setLastHomeTeam(widget.prediction.homeTeamName);
    await PreferenceService.setLastAwayTeam(widget.prediction.awayTeamName);
  }

  @override
  void dispose() {
    _simulationStartSignal.close();
    super.dispose();
  }

  void _onSimulationComplete() {
    if (mounted) {
      setState(() {
        _selectedTabIndex = 2; // Commentary tab
      });
    }
  }

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
    final apiStatus = MatchAnalysisService.apiStatus;
    final isUsingApi = apiStatus == 'API';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Prediction'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isUsingApi ? Colors.deepPurple : Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  apiStatus,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
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
                    : _selectedTabIndex == 2
                        ? _buildCommentaryTab()
                        : _buildSimulationTab(),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                      fontSize: 14,
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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                      fontSize: 14,
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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                    'Commentary',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedTabIndex == 2
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTabIndex = 3),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    border: _selectedTabIndex == 3
                        ? Border(
                            bottom: BorderSide(
                              color: Colors.deepPurple,
                              width: 3,
                            ),
                          )
                        : null,
                  ),
                  child: Text(
                    'Simulation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedTabIndex == 3
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
            const SizedBox(height: 16),
            _buildPositionLegend(),
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
            return GestureDetector(
              onTap: () {
                try {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerDetailScreen(
                        player: player,
                        teamName: team.name,
                        teamColor: color,
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error loading player details: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  print('Error navigating to player detail: $e');
                }
              },
              child: Container(
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
                      '${player.position} • ${player.subPosition}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPositionLegend() {
    final positions = [
      ('GK', Colors.purple, 'Goalkeeper'),
      ('CB/RB/LB', Colors.red, 'Defenders'),
      ('CDM/CM', Colors.amber, 'Midfielders'),
      ('CAM', Colors.green, 'Attacking Mid'),
      ('ST/RW/LW', Colors.teal, 'Forwards'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Position Legend',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: positions.map((pos) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: pos.$2,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${pos.$1} - ${pos.$3}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
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
    final gk = team.players.where((p) => p.subPosition == 'GK').toList();
    final cb = team.players.where((p) => p.subPosition == 'CB').toList();
    final rb = team.players.where((p) => p.subPosition == 'RB').toList();
    final lb = team.players.where((p) => p.subPosition == 'LB').toList();
    final cdm = team.players.where((p) => p.subPosition == 'CDM').toList();
    final cm = team.players.where((p) => p.subPosition == 'CM').toList();
    final cam = team.players.where((p) => p.subPosition == 'CAM').toList();
    final st = team.players.where((p) => p.subPosition == 'ST').toList();
    final rw = team.players.where((p) => p.subPosition == 'RW').toList();
    final lw = team.players.where((p) => p.subPosition == 'LW').toList();
    final mf = team.players.where((p) => p.position == 'MF').toList();
    final fw = team.players.where((p) => p.position == 'FW').toList();

    final players = <Map<String, String>>[];

    // GK (1)
    if (gk.isNotEmpty) {
      players.add({'name': gk[0].name, 'position': 'GK'});
    }

    // Defenders: 2 CB, 1 RB, 1 LB = 4
    for (int i = 0; i < 2 && i < cb.length; i++) {
      players.add({'name': cb[i].name, 'position': 'CB'});
    }
    if (rb.isNotEmpty) {
      players.add({'name': rb[0].name, 'position': 'RB'});
    } else if (mf.isNotEmpty) {
      players.add({'name': mf[0].name, 'position': 'RB'});
    }
    if (lb.isNotEmpty) {
      players.add({'name': lb[0].name, 'position': 'LB'});
    } else if (mf.length > 1) {
      players.add({'name': mf[1].name, 'position': 'LB'});
    }

    // Midfielders: 1 CDM, 1 CM, 1 CAM = 3
    if (cdm.isNotEmpty) {
      players.add({'name': cdm[0].name, 'position': 'CDM'});
    } else if (cm.isNotEmpty) {
      players.add({'name': cm[0].name, 'position': 'CDM'});
    } else if (mf.isNotEmpty) {
      players.add({'name': mf[2 < mf.length ? 2 : 0].name, 'position': 'CDM'});
    }
    if (cm.length > (cdm.isNotEmpty ? 0 : 1)) {
      players.add({'name': cm[cdm.isNotEmpty ? 0 : 1].name, 'position': 'CM'});
    } else if (mf.length > 2) {
      players.add({'name': mf[2].name, 'position': 'CM'});
    }
    if (cam.isNotEmpty) {
      players.add({'name': cam[0].name, 'position': 'CAM'});
    } else if (cm.length > 1) {
      players.add({'name': cm[1].name, 'position': 'CAM'});
    } else if (mf.length > 3) {
      players.add({'name': mf[3].name, 'position': 'CAM'});
    }

    // Forwards: 1 ST, 1 RW or LW = 2
    if (st.isNotEmpty) {
      players.add({'name': st[0].name, 'position': 'ST'});
    } else if (fw.isNotEmpty) {
      players.add({'name': fw[0].name, 'position': 'ST'});
    } else if (mf.isNotEmpty) {
      players.add({'name': mf[mf.length - 1].name, 'position': 'ST'});
    }
    if (rw.isNotEmpty) {
      players.add({'name': rw[0].name, 'position': 'RW'});
    } else if (lw.isNotEmpty) {
      players.add({'name': lw[0].name, 'position': 'LW'});
    } else if (fw.length > 1) {
      players.add({'name': fw[1].name, 'position': 'RW'});
    } else if (mf.isNotEmpty) {
      players.add({'name': mf[0].name, 'position': 'RW'});
    }

    // Ensure exactly 11 players
    while (players.length < 11 && team.players.isNotEmpty) {
      for (var p in team.players) {
        if (players.length >= 11) break;
        if (!players.any((pl) => pl['name'] == p.name)) {
          players.add({'name': p.name, 'position': p.position});
        }
      }
      if (players.length < 11) break;
    }

    return players.take(11).toList();
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
      {'x': 0.70, 'y': 0.55},
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
      {'x': 0.25, 'y': 0.45},
      {'x': 0.5, 'y': 0.49},
      {'x': 0.75, 'y': 0.45},
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

            _buildStatSection('🛡�E�EDefence', [
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

  Widget _buildSimulationTab() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: MatchSimulationScreen(
        prediction: widget.prediction,
        simulationStartSignal: _simulationStartSignal.stream,
        onSimulationComplete: _onSimulationComplete,
        fullscreenMode: false,
      ),
    );
  }

  Widget _buildCommentaryTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analysisResult,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🤁EAI 試合�E析を生�E中...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          final errorMsg = snapshot.error?.toString() ?? 'Unknown error';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning,
                        color: Colors.orange,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '刁E��取得エラー',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'API通信に失敗しました。フォールバック解説を表示します、En\nエラー詳細: $errorMsg',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _analysisResult =
                            MatchAnalysisService.analyzeMatch(widget.prediction);
                      });
                    },
                    child: const Text('リトライ'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('チE�Eタが利用できません'),
            ),
          );
        }

        final result = snapshot.data;
        if (result == null || result['analysis'] == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('刁E��チE�Eタが見つかりません'),
            ),
          );
        }

        final analysis = result['analysis'] as Map<String, dynamic>;
        return _SegmentedNarrativeView(analysis: analysis);
      },
    );
  }

  String? _safeGetString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    return value is String ? value : value.toString();
  }

  Widget _buildAnalysisSection(String title, String? content) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.deepPurple,
            width: 3,
          ),
        ),
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content ?? '惁E��なぁE,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrativeSegmentsSection(List<dynamic> segments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...segments.map((seg) {
          final segment = seg as Map<String, dynamic>;
          final quarter = segment['quarter'] ?? '?';
          final minuteRange = segment['minute_range'] ?? '';
          final quarterSummary = segment['quarter_summary']?.toString() ?? '';
          final events = segment['events'] as List<dynamic>?;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  border: Border(
                    left: BorderSide(
                      color: Colors.deepPurple,
                      width: 3,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Q$quarter ($minuteRange刁E',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quarterSummary,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    if (events != null && events.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...events.map((evt) {
                        final event = evt as Map<String, dynamic>;
                        final minute = event['minute']?.toString() ?? '?';
                        final team = event['team']?.toString() ?? '';
                        final eventType = event['event_type']?.toString() ?? '';
                        final description = event['description']?.toString() ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Center(
                                  child: Text(
                                    minute,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$team - $eventType',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildKeyMomentsSection(Map<String, dynamic> analysis) {
    final keyMoments = analysis['keyMoments'] as List<dynamic>? ??
        analysis['key_moments'] as List<dynamic>?;
    if (keyMoments == null || keyMoments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.deepPurple,
            width: 3,
          ),
        ),
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '重要な場面',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          ...keyMoments.map((moment) {
            final m = moment as Map<String, dynamic>;
            final minute = m['minute']?.toString() ?? '?';
            final event = m['event']?.toString() ?? 'イベンチE;
            final team = m['team']?.toString() ?? '';
            final description = m['description']?.toString() ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        minute,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$team - $event',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
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
    final gk = team.players.where((p) => p.subPosition == 'GK').toList();
    final cb = team.players.where((p) => p.subPosition == 'CB').toList();
    final rb = team.players.where((p) => p.subPosition == 'RB').toList();
    final lb = team.players.where((p) => p.subPosition == 'LB').toList();
    final cdm = team.players.where((p) => p.subPosition == 'CDM').toList();
    final cm = team.players.where((p) => p.subPosition == 'CM').toList();
    final cam = team.players.where((p) => p.subPosition == 'CAM').toList();
    final st = team.players.where((p) => p.subPosition == 'ST').toList();
    final rw = team.players.where((p) => p.subPosition == 'RW').toList();
    final lw = team.players.where((p) => p.subPosition == 'LW').toList();

    final players = <Map<String, String>>[];

    if (gk.isNotEmpty) players.add({'name': gk[0].name, 'position': 'GK'});

    // Defenders: 2 CB, 1 RB, 1 LB
    for (int i = 0; i < 2 && i < cb.length; i++) {
      players.add({'name': cb[i].name, 'position': 'CB'});
    }
    if (rb.isNotEmpty) {
      players.add({'name': rb[0].name, 'position': 'RB'});
    }
    if (lb.isNotEmpty) {
      players.add({'name': lb[0].name, 'position': 'LB'});
    }

    // Midfielders: 1 CDM, 1 CM, 1 CAM
    if (cdm.isNotEmpty) {
      players.add({'name': cdm[0].name, 'position': 'CDM'});
    } else if (cm.isNotEmpty) {
      players.add({'name': cm[0].name, 'position': 'CM'});
    }
    if (cm.isNotEmpty) {
      players.add({'name': cm[0].name, 'position': 'CM'});
    }
    if (cam.isNotEmpty) {
      players.add({'name': cam[0].name, 'position': 'CAM'});
    } else if (cm.length > 1) {
      players.add({'name': cm[1].name, 'position': 'CM'});
    }

    // Forwards: 1 ST, 1 RW or LW
    if (st.isNotEmpty) {
      players.add({'name': st[0].name, 'position': 'ST'});
    }
    if (rw.isNotEmpty) {
      players.add({'name': rw[0].name, 'position': 'RW'});
    } else if (lw.isNotEmpty) {
      players.add({'name': lw[0].name, 'position': 'LW'});
    }

    return players;
  }

  Color _getPositionColor(String? position) {
    switch (position) {
      case 'GK':
        return Colors.purple;
      case 'CB':
      case 'RB':
      case 'LB':
        return Colors.red;
      case 'CDM':
      case 'CM':
        return Colors.amber;
      case 'CAM':
        return Colors.green;
      case 'ST':
      case 'RW':
      case 'LW':
        return Colors.teal;
      default:
        return Colors.grey;
    }
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getPositionColor(player['position']),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isHome ? Colors.blue : Colors.orange,
                  width: 3,
                ),
              ),
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
            Container(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                player['position'] ?? 'GK',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getPositionColor(player['position']),
                  fontWeight: FontWeight.bold,
                  fontSize: 7,
                  backgroundColor: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ],
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

class _SegmentedNarrativeView extends StatefulWidget {
  final Map<String, dynamic> analysis;

  const _SegmentedNarrativeView({
    required this.analysis,
  });

  @override
  State<_SegmentedNarrativeView> createState() =>
      _SegmentedNarrativeViewState();
}

class _SegmentedNarrativeViewState extends State<_SegmentedNarrativeView> {

  @override
  Widget build(BuildContext context) {
    final segments =
        (widget.analysis['narrative_segments'] ?? []) as List<dynamic>;
    final summary = widget.analysis['overall_summary'] ?? '';
    final keyMoments = (widget.analysis['key_moments'] ?? []) as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildQuarterCard(
                segments.length > index
                    ? segments[index]
                    : {
                        'quarter': index + 1,
                        'narrative': '',
                        'events': [],
                        'quarter_score': '0-0',
                        'quarter_summary': '',
                      },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildSummaryCard(summary, keyMoments),
          ),
        ],
      ),
    );
  }

  Widget _buildQuarterCard(Map<String, dynamic> segment) {
    final quarterNum = segment['quarter'] ?? 0;
    final narrative = _safeGetString(
        segment, 'narrative', '試合�E実況が生�EされてぁE��ぁE..');
    final events = (segment['events'] ?? []) as List<dynamic>;
    final score = _safeGetString(segment, 'quarter_score', '0-0');
    final summary = _safeGetString(segment, 'quarter_summary', '');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '第${quarterNum}クォーター',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    score,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              narrative,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'イベンチE,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildEventTimeline(events),
            ],
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                summary,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventTimeline(List<dynamic> events) {
    return Column(
      children: List.generate(
        events.length,
        (index) {
          final event = events[index] as Map<String, dynamic>;
          final minute = _safeGetString(event, 'minute', '');
          final team = _safeGetString(event, 'team', '');
          final eventType = _safeGetString(event, 'event', '');
          final description = _safeGetString(event, 'description', '');

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    minute,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$team - ${_getEventIcon(eventType)} $eventType',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String summary, List<dynamic> keyMoments) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '総括',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            if (keyMoments.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                '重要な場面',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                keyMoments.length,
                (index) {
                  final moment = keyMoments[index] as Map<String, dynamic>;
                  final minute = _safeGetString(moment, 'minute', '');
                  final event = _safeGetString(moment, 'event', '');
                  final team = _safeGetString(moment, 'team', '');
                  final desc = _safeGetString(moment, 'description', '');

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              minute,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text('$team - ${_getEventIcon(event)}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(desc),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getEventIcon(String eventType) {
    return switch (eventType.toLowerCase()) {
      'ゴール' || 'goal' => '⚽',
      'シューチE || 'shoot' || 'shot' => '🎯',
      'ファウル' || 'foul' => '🚨',
      'セーチE || 'save' => '🧤',
      'チャンス' || 'chance' => '💥',
      'パス' || 'pass' => '👟',
      _ => '•',
    };
  }

  String _safeGetString(
      Map<String, dynamic> map, String key, String defaultValue) {
    try {
      final value = map[key];
      if (value == null) return defaultValue;
      return value.toString();
    } catch (e) {
      return defaultValue;
    }
  }
}

