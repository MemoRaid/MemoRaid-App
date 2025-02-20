import 'package:flutter/material.dart';
import 'bottomnavbar.dart';
import 'dart:async';
import 'package:vibration/vibration.dart';
import 'analyticsbreath.dart';

class BreathExerciseScreen extends StatefulWidget {
  const BreathExerciseScreen({super.key});

  @override
  _BreathExerciseScreenState createState() => _BreathExerciseScreenState();
}

class _BreathExerciseScreenState extends State<BreathExerciseScreen>
    with SingleTickerProviderStateMixin {
  double _logoSize = 120;
  String _instruction = "Tap to Start";
  bool _isAnimating = false;
  Timer? _timer;
  int _step = 0;
  int _cycles = 0;
  int _totalSeconds = 0;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(_controller);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startBreathingExercise() {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _instruction = "Inhale...";
      _logoSize = 200;
      _cycles = 0;
      _totalSeconds = 0;
    });

    _triggerVibration();

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _totalSeconds += 4;
        if (_step == 0) {
          _instruction = "Hold...";
          _logoSize = 220;
        } else if (_step == 1) {
          _instruction = "Exhale...";
          _logoSize = 120;
          _cycles++;
        } else {
          _instruction = "Inhale...";
          _logoSize = 200;
        }
        _triggerVibration();
        _step = (_step + 1) % 3;
      });
    });
  }

  void _stopBreathingExercise() {
    _timer?.cancel();
    setState(() {
      _isAnimating = false;
      _logoSize = 120;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalyticsScreen(
          totalSeconds: _totalSeconds,
          cycles: _cycles,
        ),
      ),
    );
  }

  void _triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D3445),
              Color(0xFF1C5D7A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Breath Exercise",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to center the title
                  ],
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 4),
                        curve: Curves.easeInOut,
                        width: _logoSize,
                        height: _logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                            image: AssetImage("lib/assets/images/memoraid.png"),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            if (_isAnimating)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.8),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Instruction Text
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _instruction,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Start/Stop Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0D3445),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        elevation: 6,
                      ),
                      onPressed: _isAnimating
                          ? _stopBreathingExercise
                          : _startBreathingExercise,
                      child: Text(
                        _isAnimating ? "Stop Exercise" : "Start Exercise",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Breathing Benefits Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "🧠 How does breathing help amnesia?",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "• Increases oxygen supply to the brain\n"
                            "• Reduces stress and anxiety\n"
                            "• Enhances memory and cognitive function\n"
                            "• Promotes relaxation and focus",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/progress');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/chatbot');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/rocket');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/achievements');
              break;
          }
        },
      ),
    );
  }
}
