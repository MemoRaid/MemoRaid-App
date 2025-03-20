import 'package:flutter/material.dart';
import '../features/g_02_level_selection_screen.dart';

class MemoryRecoveryApp extends StatelessWidget {
  const MemoryRecoveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memory Recovery Game',
      theme: ThemeData(
        primarySwatch: MaterialColor(
          0xFF0D3445, // Primary color #0D3445
          <int, Color>{
            50: const Color(0xFF0D3445).withOpacity(0.1),
            100: const Color(0xFF0D3445).withOpacity(0.2),
            200: const Color(0xFF0D3445).withOpacity(0.3),
            300: const Color(0xFF0D3445).withOpacity(0.4),
            400: const Color(0xFF0D3445).withOpacity(0.5),
            500: const Color(0xFF0D3445),
            600: const Color(0xFF0D3445).withOpacity(0.7),
            700: const Color(0xFF0D3445).withOpacity(0.8),
            800: const Color(0xFF0D3445).withOpacity(0.9),
            900: const Color(0xFF0D3445),
          },
        ),
        scaffoldBackgroundColor: const Color(0xFF0D3445).withOpacity(0.1),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D3445),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const LevelSelectionScreen(),
    );
  }
}
