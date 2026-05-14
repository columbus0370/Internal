import 'package:flutter/material.dart';
import 'dart:async';

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

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _dotController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
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
