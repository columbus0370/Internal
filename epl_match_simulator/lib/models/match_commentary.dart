class MatchCommentary {
  final int minute;
  final String period; // 前半、後半
  final String action; // ドリブル、パス、シュート、セーブなど
  final String playerName;
  final String teamName;
  final String description;

  MatchCommentary({
    required this.minute,
    required this.period,
    required this.action,
    required this.playerName,
    required this.teamName,
    required this.description,
  });

  @override
  String toString() => '$period${minute}分: $description';
}
