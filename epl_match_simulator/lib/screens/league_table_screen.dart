import 'package:flutter/material.dart';
import '../models/league_standing.dart';

class LeagueTableScreen extends StatelessWidget {
  final List<LeagueStanding> standings;

  const LeagueTableScreen({
    super.key,
    required this.standings,
  });

  Color _getRowColor(int position) {
    if (position <= 4) return Colors.blue.withOpacity(0.1);
    if (position <= 6) return Colors.purple.withOpacity(0.1);
    if (position == 7) return Colors.orange.withOpacity(0.1);
    if (position >= 18) return Colors.red.withOpacity(0.1);
    return Colors.transparent;
  }

  String _getQualificationLabel(int position) {
    if (position <= 4) return 'CL';
    if (position <= 6) return 'EL';
    if (position == 7) return 'ECL';
    if (position >= 18) return 'REL';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premier League Table'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegend(),
            const SizedBox(height: 16),
            _buildTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildLegendItem('Champions League', Colors.blue),
          const SizedBox(width: 12),
          _buildLegendItem('Europa League', Colors.purple),
          const SizedBox(width: 12),
          _buildLegendItem('Conference League', Colors.orange),
          const SizedBox(width: 12),
          _buildLegendItem('Relegation', Colors.red),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(0.8),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(0.8),
        3: FlexColumnWidth(0.8),
        4: FlexColumnWidth(0.8),
        5: FlexColumnWidth(0.8),
        6: FlexColumnWidth(0.8),
        7: FlexColumnWidth(1),
      },
      border: TableBorder.all(color: Colors.grey[300]!),
      children: [
        _buildHeaderRow(),
        ...standings.map((standing) => _buildTeamRow(standing)),
      ],
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1)),
      children: [
        _buildTableCell('Pos', isHeader: true),
        _buildTableCell('Team', isHeader: true),
        _buildTableCell('P', isHeader: true),
        _buildTableCell('W', isHeader: true),
        _buildTableCell('D', isHeader: true),
        _buildTableCell('L', isHeader: true),
        _buildTableCell('GD', isHeader: true),
        _buildTableCell('Pts', isHeader: true),
      ],
    );
  }

  TableRow _buildTeamRow(LeagueStanding standing) {
    final bgColor = _getRowColor(standing.position);
    final qualLabel = _getQualificationLabel(standing.position);

    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        _buildTableCell('${standing.position}'),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                standing.teamName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
              if (qualLabel.isNotEmpty)
                Text(
                  qualLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
        _buildTableCell('${standing.played}'),
        _buildTableCell('${standing.won}'),
        _buildTableCell('${standing.drawn}'),
        _buildTableCell('${standing.lost}'),
        _buildTableCell('${standing.goalDifference}', highlight: standing.goalDifference < 0),
        _buildTableCell('${standing.points}', bold: true),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false, bool highlight = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isHeader || bold ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 12 : 11,
          color: highlight ? Colors.red : null,
        ),
      ),
    );
  }
}
