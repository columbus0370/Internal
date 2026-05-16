import 'package:flutter/material.dart';
import 'dart:async';

class MatchSimulationLoading extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;

  const MatchSimulationLoading({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  State<MatchSimulationLoading> createState() => _MatchSimulationLoadingState();
}

class _MatchSimulationLoadingState extends State<MatchSimulationLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _ballController;
  late Timer _eventTimer;
  int _currentMinute = 0;
  String _currentEvent = '';
  late List<String> _events;

  final List<String> _eventPatterns = [
    '第{m}分: シュート！',
    '第{m}分: コーナーキック',
    '第{m}分: ファウル',
    '第{m}分: ゴール！⚽',
    '第{m}分: ドリブル突破',
    '第{m}分: パスカット',
    '第{m}分: 激しい攻撃',
    '第{m}分: ボール奪取',
    '第{m}分: ヘディング',
    '第{m}分: スローイン',
  ];

  @override
  void initState() {
    super.initState();
    _ballController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _events = _generateEvents();
    _startSimulation();
  }

  List<String> _generateEvents() {
    final events = <String>[];
    for (int i = 0; i < 90; i += 15) {
      final pattern = _eventPatterns[i % _eventPatterns.length];
      events.add(pattern.replaceAll('{m}', (i + 15).toString()));
    }
    return events;
  }

  void _startSimulation() {
    _eventTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        if (_currentMinute < 90) {
          _currentMinute++;
          if (_currentMinute % 15 == 0) {
            final index = (_currentMinute ~/ 15) - 1;
            if (index < _events.length) {
              _currentEvent = _events[index];
            }
          }
        } else {
          _eventTimer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _ballController.dispose();
    _eventTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // スコアボード
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.deepPurple,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.homeTeam,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(_currentMinute ~/ 45) + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.awayTeam,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 試合時間
              Text(
                '第$_currentMinute分',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        // サッカーボール回転アニメーション
        RotationTransition(
          turns: _ballController,
          child: const Text(
            '⚽',
            style: TextStyle(fontSize: 60),
          ),
        ),
        const SizedBox(height: 40),
        // イベント表示
        Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.orange,
              width: 1.5,
            ),
          ),
          child: Text(
            _currentEvent.isEmpty ? '試合開始...' : _currentEvent,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _currentEvent.isEmpty
                  ? Colors.grey
                  : Colors.orange[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 40),
        // プログレスバー
        Container(
          width: 300,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _currentMinute / 90,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.deepPurple,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '試合をシミュレーション中...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
