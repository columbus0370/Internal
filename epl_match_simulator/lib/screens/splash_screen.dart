import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _dotController;
  late AnimationController _fadeController;
  late List<AnimationController> _emblemControllers;

  final List<String> allTeams = [
    'Arsenal', 'Manchester City', 'Manchester United', 'Liverpool',
    'Aston Villa', 'AFC Bournemouth', 'Brighton & Hove Albion', 'Brentford',
    'Tottenham Hotspur', 'Fulham', 'Newcastle United', 'Nottingham Forest',
    'Crystal Palace', 'Chelsea', 'Everton', 'West Ham United',
    'Leeds United', 'Sunderland', 'Burnley', 'Wolverhampton Wanderers',
  ];

  late List<String> selectedTeams;
  late List<Offset> emblemPositions;
  late List<Offset> targetPositions;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _dotController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    // Select 6 random teams
    selectedTeams = (allTeams..shuffle()).take(6).toList();
    emblemPositions = List.generate(6, (_) => _randomOffset());
    targetPositions = List.generate(6, (_) => _randomOffset());

    // Create animation controllers for each emblem
    _emblemControllers = List.generate(6, (_) {
      return AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      )..repeat();
    });

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  Offset _randomOffset() {
    return Offset(
      _random.nextDouble() * 0.6 - 0.3,
      _random.nextDouble() * 0.6 - 0.3,
    );
  }

  String _teamToAsset(String team) {
    return team.replaceAll(' ', '_').replaceAll('&', 'and').replaceAll("'", '').toLowerCase();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _dotController.dispose();
    _fadeController.dispose();
    for (var controller in _emblemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepPurple.shade900,
                  Colors.deepPurple.shade700,
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                ],
              ),
            ),
          ),

          // Animated team emblems in background
          Positioned.fill(
            child: Stack(
              children: List.generate(6, (index) {
                return AnimatedBuilder(
                  animation: _emblemControllers[index],
                  builder: (context, child) {
                    final progress = _emblemControllers[index].value;
                    final startPos = emblemPositions[index];
                    final endPos = targetPositions[index];
                    final currentPos = Offset(
                      startPos.dx + (endPos.dx - startPos.dx) * progress,
                      startPos.dy + (endPos.dy - startPos.dy) * progress,
                    );

                    if (progress > 0.95) {
                      emblemPositions[index] = targetPositions[index];
                      targetPositions[index] = _randomOffset();
                      _emblemControllers[index].reset();
                    }

                    return Positioned(
                      left: (MediaQuery.of(context).size.width / 2) + currentPos.dx * 200,
                      top: (MediaQuery.of(context).size.height / 3) + currentPos.dy * 200,
                      child: SvgEmblem(
                        team: selectedTeams[index],
                        opacity: 0.1,
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildRotatingGradientBall(),
                    RotationTransition(
                      turns: _rotationController,
                      child: Text(
                        '⚽',
                        style: TextStyle(
                          fontSize: 80,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  'EPL Match Predictor',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI is analyzing the match data',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),
                _buildLoadingDots(),
                const SizedBox(height: 40),
                _buildPLBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingGradientBall() {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(_rotationController),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: Tween(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(
              parent: _dotController,
              curve: Interval(
                index * 0.2,
                (index + 1) * 0.2 + 0.4,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPLBadge() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
            style: TextStyle(fontSize: 24, shadows: [
              Shadow(
                blurRadius: 5,
                color: Colors.black.withOpacity(0.3),
              ),
            ]),
          ),
          const SizedBox(width: 8),
          Text(
            'Premier League',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class SvgEmblem extends StatelessWidget {
  final String team;
  final double opacity;

  const SvgEmblem({
    super.key,
    required this.team,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final assetName = team.replaceAll(' ', '_').replaceAll('&', 'and').replaceAll("'", '').toLowerCase();

    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.asset(
          'assets/emblems/$assetName.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
