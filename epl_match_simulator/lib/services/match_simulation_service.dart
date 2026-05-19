import 'dart:async';
import '../models/match_prediction.dart';
import '../models/simulation_event.dart';

class MatchSimulationService {
  final MatchPrediction prediction;
  late Timer _timer;
  late StreamController<SimulationEvent> _eventStreamController;

  int _currentMinute = 0;
  int _homeScore = 0;
  int _awayScore = 0;
  bool _isRunning = false;
  double _speedMultiplier = 1.0;
  final List<SimulationEvent> _allEvents = [];

  MatchSimulationService({required this.prediction}) {
    _eventStreamController = StreamController<SimulationEvent>.broadcast();
    _homeScore = 0;
    _awayScore = 0;
  }

  Stream<SimulationEvent> get eventStream => _eventStreamController.stream;
  int get currentMinute => _currentMinute;
  int get homeScore => _homeScore;
  int get awayScore => _awayScore;
  bool get isRunning => _isRunning;

  Future<void> startSimulation() async {
    if (_isRunning) return;

    _isRunning = true;
    _currentMinute = 0;
    _homeScore = 0;
    _awayScore = 0;
    _allEvents.clear();

    // Generate all events
    _allEvents.addAll(_generatePhaseEvents());
    _allEvents.addAll(_extractGoalEvents());
    _allEvents.sort((a, b) => a.minute.compareTo(b.minute));

    // Emit kickoff
    final kickoffEvent = SimulationEvent(
      type: EventType.kickoff,
      minute: 0,
      team: prediction.homeTeamName,
      details: {'message': 'Match starts!'},
    );

    try {
      _eventStreamController.add(kickoffEvent);
    } catch (e) {
      print('Error emitting kickoff event: $e');
      _isRunning = false;
      return;
    }

    // Start timer with speed multiplier applied
    final baseInterval = Duration(milliseconds: 500);
    final actualInterval = Duration(
      milliseconds: (baseInterval.inMilliseconds / _speedMultiplier).round(),
    );

    try {
      _timer = Timer.periodic(actualInterval, (timer) {
        _processNextMinute();
      });
    } catch (e) {
      print('Error creating timer: $e');
      _isRunning = false;
      rethrow;
    }
  }

  void pause() {
    if (!_isRunning) return;
    _isRunning = false;
    _timer.cancel();
  }

  void resume() {
    if (_isRunning) return;
    if (_currentMinute >= 90) return;

    _isRunning = true;
    final baseInterval = Duration(milliseconds: 500);
    final actualInterval = Duration(
      milliseconds: (baseInterval.inMilliseconds / _speedMultiplier).round(),
    );
    _timer = Timer.periodic(actualInterval, (timer) {
      _processNextMinute();
    });
  }

  void reset() {
    if (_isRunning) {
      _timer.cancel();
    }
    _isRunning = false;
    _currentMinute = 0;
    _homeScore = 0;
    _awayScore = 0;
    _eventStreamController.close();
    _eventStreamController = StreamController<SimulationEvent>.broadcast();
  }

  void setSpeed(double multiplier) {
    _speedMultiplier = multiplier.clamp(0.5, 4.0);

    // If simulation is running, restart timer with new speed
    if (_isRunning) {
      _timer.cancel();
      final baseInterval = Duration(milliseconds: 500);
      final actualInterval = Duration(
        milliseconds: (baseInterval.inMilliseconds / _speedMultiplier).round(),
      );
      _timer = Timer.periodic(actualInterval, (timer) {
        _processNextMinute();
      });
    }
  }

  void _processNextMinute() {
    if (_currentMinute >= 90) {
      _isRunning = false;
      _timer.cancel();

      final fullTimeEvent = SimulationEvent(
        type: EventType.fullTime,
        minute: 90,
        team: '',
        details: {
          'homeScore': _homeScore,
          'awayScore': _awayScore,
          'result': _homeScore > _awayScore
              ? '${prediction.homeTeamName} wins'
              : _awayScore > _homeScore
                  ? '${prediction.awayTeamName} wins'
                  : 'Draw'
        },
      );

      try {
        _eventStreamController.add(fullTimeEvent);
      } catch (e) {
        print('Error emitting fulltime event: $e');
      }
      return;
    }

    // Emit all events for current minute and update scores atomically
    final eventsAtMinute = _allEvents.where((e) => e.minute == _currentMinute).toList();

    // Update scores first before emitting events
    for (final event in eventsAtMinute) {
      if (event.type == EventType.goal) {
        if (event.team == prediction.homeTeamName) {
          _homeScore++;
        } else {
          _awayScore++;
        }
      }
    }

    // Emit all events for this minute
    for (final event in eventsAtMinute) {
      try {
        _eventStreamController.add(event);
      } catch (e) {
        print('Error emitting event at minute $_currentMinute: $e');
      }
    }

    _currentMinute++;
  }

  List<SimulationEvent> _generatePhaseEvents() {
    final events = <SimulationEvent>[];

    // Halftime
    events.add(SimulationEvent(
      type: EventType.halftime,
      minute: 45,
      team: '',
      details: {
        'homeScore': prediction.homeScore ~/ 2,
        'awayScore': prediction.awayScore ~/ 2,
      },
    ));

    // Second half start
    events.add(SimulationEvent(
      type: EventType.secondHalfStart,
      minute: 46,
      team: prediction.homeTeamName,
      details: {'message': 'Second half begins'},
    ));

    return events;
  }

  List<SimulationEvent> _extractGoalEvents() {
    final events = <SimulationEvent>[];

    for (final goal in prediction.goals) {
      // Parse minute from string (e.g., "23", "45+2")
      int minute = 0;

      // Validate input
      if (goal.minute == null || goal.minute.isEmpty) {
        continue;
      }

      try {
        final minuteStr = goal.minute.trim();

        if (minuteStr.contains('+')) {
          final parts = minuteStr.split('+');
          if (parts.length != 2) continue;

          // Parse both parts
          final mainMinute = int.parse(parts[0].trim());
          final addedTime = int.parse(parts[1].trim());

          // Validate ranges
          if (mainMinute < 0 || mainMinute > 90 || addedTime < 0) {
            continue;
          }

          minute = mainMinute + addedTime;
        } else {
          minute = int.parse(minuteStr);

          // Validate range
          if (minute < 0 || minute > 90) {
            continue;
          }
        }
      } catch (e) {
        // Skip invalid minute values
        continue;
      }

      // Clamp to 90 as maximum
      if (minute > 90) minute = 90;

      events.add(SimulationEvent(
        type: EventType.goal,
        minute: minute,
        team: goal.team,
        details: {
          'scorer': goal.scorer,
          'assist': goal.assist,
        },
      ));
    }

    return events;
  }

  void dispose() {
    if (_isRunning) {
      _timer.cancel();
    }
    _eventStreamController.close();
  }
}
