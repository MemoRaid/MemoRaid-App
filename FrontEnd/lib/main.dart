import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/homescreen02.dart';
import 'features/splash.dart';
import 'features/homescreen01.dart';
import 'features/chatbot.dart';
import 'features/login.dart';
import 'features/signup.dart';
import 'features/leaderboard.dart';
import 'features/settings1.dart';
import 'features/user_provider.dart';
import 'features/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MemoRaid',
          theme: themeProvider.getTheme(),
          initialRoute: '/', // Set initial route to splash screen
          routes: {
            '/': (context) => const SplashScreen(), // Initial splash screen
            '/home': (context) => const HomeScreen(), // Home screen
            '/progress': (context) => const LoginScreen(), // Progress graph
            '/chatbot': (context) => const ChatScreen(), // AI Chatbot
            '/rocket': (context) => const SignUpScreen(), // Rocket feature
            '/achievements': (context) =>
                const LeaderboardScreen(), // Achievements
            '/settings': (context) => const SettingsScreen(), // Settings screen
          },
        );
      },
    );
  }
}
