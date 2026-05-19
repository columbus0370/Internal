import 'package:flutter/material.dart';
import '../models/match_prediction.dart';
import '../models/simulation_event.dart';
import '../services/match_simulation_service.dart';
import '../widgets/match_simulation_widgets.dart';

class MatchSimulationScreen extends StatefulWidget {
  final MatchPrediction prediction;

  const MatchSimulationScreen({
    super.key,
    required this.prediction,
  });

  @override
  State<MatchSimulationScreen> createState() => _MatchSimulationScreenState();
}

class _MatchSimulationScreenState extends State<MatchSimulationScreen> {
  late MatchSimulationService _simulationService;
  final List<SimulationEvent> _events = [];
  double _speedMultiplier = 1.0;

  @override
  void initState() {
    super.initState();
    _simulationService = MatchSimulationService(prediction: widget.prediction);
  }

  @override
  void dispose() {
    _simulationService.dispose();
    super.dispose();
  }

  Future<void> _handlePlay() async {
    if (!_simulationService.isRunning) {
      if (_simulationService.currentMinute == 0) {
        await _simulationService.startSimulation();
      } else {
        _simulationService.resume();
      }
      setState(() {});
    }
  }

  void _handlePause() {
    _simulationService.pause();
    setState(() {});
  }

  void _handleReset() {
    _simulationService.reset();
    _events.clear();
    setState(() {});
  }

  void _handleSpeedChanged(double speed) {
    _speedMultiplier = speed;
    _simulationService.setSpeed(speed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Match Simulation'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<SimulationEvent>(
        stream: _simulationService.eventStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final event = snapshot.data!;
            // Only add non-phase events and unique events
            if (event.type != EventType.possession &&
                !_events.any(
                    (e) => e.minute == event.minute && e.type == event.type)) {
              _events.add(event);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Scoreboard
                StreamBuilder<SimulationEvent>(
                  stream: _simulationService.eventStream,
                  builder: (context, snapshot) {
                    return ScoreBoardWidget(
                      homeTeam: widget.prediction.homeTeamName,
                      awayTeam: widget.prediction.awayTeamName,
                      homeScore: _simulationService.homeScore,
                      awayScore: _simulationService.awayScore,
                      minute: _simulationService.currentMinute,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Progress bar
                StreamBuilder<SimulationEvent>(
                  stream: _simulationService.eventStream,
                  builder: (context, snapshot) {
                    return ProgressBarWidget(
                      minute: _simulationService.currentMinute,
                      totalMinutes: 90,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Event timeline
                EventTimelinePanelWidget(
                  events: _events,
                  currentMinute: _simulationService.currentMinute,
                ),
                const SizedBox(height: 16),

                // Controls
                ControlsPanelWidget(
                  isRunning: _simulationService.isRunning,
                  onPlay: _handlePlay,
                  onPause: _handlePause,
                  onReset: _handleReset,
                  onSpeedChanged: _handleSpeedChanged,
                  currentSpeed: _speedMultiplier,
                ),
                const SizedBox(height: 24),

                // Match summary section (show at full time)
                if (_simulationService.currentMinute == 90)
                  Card(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Final Score',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    widget.prediction.homeTeamName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _simulationService.homeScore.toString(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    widget.prediction.awayTeamName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    _simulationService.awayScore.toString(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
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

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
