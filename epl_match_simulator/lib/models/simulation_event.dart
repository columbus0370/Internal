enum EventType {
  kickoff,
  goal,
  possession,
  chance,
  halftime,
  secondHalfStart,
  fullTime,
}

class SimulationEvent {
  final EventType type;
  final int minute;
  final String team;
  final Map<String, dynamic> details;

  SimulationEvent({
    required this.type,
    required this.minute,
    required this.team,
    this.details = const {},
  });

  String get typeLabel => _getTypeLabel();

  String _getTypeLabel() {
    switch (type) {
      case EventType.kickoff:
        return 'Kickoff';
      case EventType.goal:
        return 'Goal';
      case EventType.possession:
        return 'Possession';
      case EventType.chance:
        return 'Chance';
      case EventType.halftime:
        return 'Halftime';
      case EventType.secondHalfStart:
        return 'Second Half';
      case EventType.fullTime:
        return 'Full Time';
    }
  }

  String get icon => _getIcon();

  String _getIcon() {
    switch (type) {
      case EventType.kickoff:
        return '🏁';
      case EventType.goal:
        return '⚽';
      case EventType.possession:
        return '🎾';
      case EventType.chance:
        return '💥';
      case EventType.halftime:
        return '⏸️';
      case EventType.secondHalfStart:
        return '▶️';
      case EventType.fullTime:
        return '🏁';
    }
  }
}
