import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/homescreen02.dart';
import 'features/splash.dart';
import 'features/homescreen01.dart';
import 'features/chatbot.dart';
import 'features/login.dart';
import 'features/signup.dart';
import 'features/leaderboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MemoRaid',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D3445), // Global background color
          selectedItemColor: Colors.white, // Selected item color
          unselectedItemColor: Colors.grey, // Unselected item color
        ),
      ),
      initialRoute: '/', // Set initial route to splash screen
      routes: {
        '/': (context) => const SplashScreen(), // Initial splash screen
        '/home': (context) => const HomeScreen(), // Home screen
        '/progress': (context) => const LoginScreen(), // Progress graph
        '/chatbot': (context) => const ChatScreen(), // AI Chatbot
        '/rocket': (context) => const SignUpScreen(), // Rocket feature
        '/achievements': (context) => const LeaderboardScreen(), // Achievements
      },
    );
  }
}
