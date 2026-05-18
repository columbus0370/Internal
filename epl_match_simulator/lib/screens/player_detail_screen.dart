import 'package:flutter/material.dart';
import '../models/team.dart';

class PlayerDetailScreen extends StatelessWidget {
  final Player player;
  final String teamName;
  final Color teamColor;

  const PlayerDetailScreen({
    super.key,
    required this.player,
    required this.teamName,
    required this.teamColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player card with basic info
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: teamColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          player.name.split(' ').last.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      teamName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              player.position,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Position',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              player.subPosition,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sub-Position',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Overall Rating Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Rating',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${player.overallRating.clamp(0, 100)}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: _getRatingColor(player.overallRating),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (player.overallRating / 100.0).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getRatingColor(player.overallRating),
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rating out of 100',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detailed Stats
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detailed Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      'Attack',
                      player.attackRating,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Defense',
                      player.defenseRating,
                      Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Passing',
                      player.passingRating,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Position Guide
            Card(
              color: Colors.deepPurple.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Position Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPositionInfo(player.position, player.subPosition),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Back button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Back to Match',
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

  Widget _buildStatRow(String label, int value, Color color) {
    // Clamp value between 0-100 to prevent display errors
    final clampedValue = value.clamp(0, 100);
    final displayValue = clampedValue > 100 ? 100 : clampedValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$displayValue',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (displayValue / 100.0).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildPositionInfo(String position, String subPosition) {
    String description = '';
    switch (subPosition) {
      case 'GK':
        description = 'Goalkeeper - Primary shot-stopper and goalkeeper for the team.';
        break;
      case 'CB':
        description =
            'Center Back - Central defender responsible for blocking shots and defending against forwards.';
        break;
      case 'RB':
        description =
            'Right Back - Right-side defender responsible for defending and supporting the right wing.';
        break;
      case 'LB':
        description =
            'Left Back - Left-side defender responsible for defending and supporting the left wing.';
        break;
      case 'CDM':
        description =
            'Central Defensive Midfielder - Protects the defense by breaking up opposition attacks.';
        break;
      case 'CM':
        description =
            'Central Midfielder - Box-to-box midfielder balancing defense and attack contributions.';
        break;
      case 'CAM':
        description =
            'Central Attacking Midfielder - Creative playmaker supporting forwards with key passes.';
        break;
      case 'RW':
        description = 'Right Winger - Right-side attacker creating chances and crossing the ball.';
        break;
      case 'LW':
        description = 'Left Winger - Left-side attacker creating chances and crossing the ball.';
        break;
      case 'ST':
        description = 'Striker - Center forward responsible for finishing chances and scoring goals.';
        break;
      default:
        description = '$position / $subPosition';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            subPosition,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 88) return Colors.green;
    if (rating >= 85) return Colors.lightGreen;
    if (rating >= 80) return Colors.yellow[700]!;
    if (rating >= 75) return Colors.orange;
    return Colors.red;
  }
}
