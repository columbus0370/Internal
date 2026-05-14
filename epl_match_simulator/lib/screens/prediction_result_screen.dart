import 'package:flutter/material.dart';
import '../models/match_prediction.dart';

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
            const SizedBox(height: 16),
            Text(
              'Formation Preview',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Team formations and player positions will be displayed here',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
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
