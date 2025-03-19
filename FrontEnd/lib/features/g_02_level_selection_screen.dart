import 'package:flutter/material.dart';
import '../features/g_02_memory_game_home.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0D3445);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF185373),
                        Color(0xFF0A2836),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Memory Master',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Color.fromARGB(130, 0, 0, 0),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Select a Level to Play',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Level cards
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      // Level 1 - Hobbies
                      _buildLevelCard(
                        context,
                        title: 'Level 1',
                        theme: 'Hobbies',
                        time: '90 sec',
                        difficulty: 'Tutorial',
                        icon: Icons.theater_comedy,
                        color: Colors.green,
                      ),

                      // Level 2 - Places
                      _buildLevelCard(
                        context,
                        title: 'Level 2',
                        theme: 'Places',
                        time: '75 sec',
                        difficulty: 'Easy',
                        icon: Icons.home_work,
                        color: Colors.lightBlue,
                      ),

                      // Level 3 - Family
                      _buildLevelCard(
                        context,
                        title: 'Level 3',
                        theme: 'Family',
                        time: '60 sec',
                        difficulty: 'Medium',
                        icon: Icons.family_restroom,
                        color: Colors.orange,
                      ),

                      // Level 4 - Mixed
                      _buildLevelCard(
                        context,
                        title: 'Level 4',
                        theme: 'Mixed',
                        time: '45 sec',
                        difficulty: 'Hard',
                        icon: Icons.shuffle,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
