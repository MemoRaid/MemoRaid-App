import 'package:flutter/material.dart';

import 'package:confetti/confetti.dart';

class ResultsScreen extends StatefulWidget {
  final int score;
  final int totalScenarios;

  const ResultsScreen({
    super.key,
    required this.score,
    required this.totalScenarios,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade700, Colors.indigo.shade300],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 80,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You completed all scenarios!',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Animated score counter
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: widget.score),
                      duration: Duration(seconds: 2),
                      builder: (context, value, child) {
                        return Text(
                          'Total Score: $value',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.indigo.shade700,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }
}
