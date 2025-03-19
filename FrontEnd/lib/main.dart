import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/splash.dart';
import 'features/homescreen01.dart';
import 'features/chatbot.dart';
import 'features/leaderboard.dart';
import 'features/settings1.dart';
import 'features/user_provider.dart';
import 'features/theme_provider.dart';
import 'features/help_center_screen.dart';
import 'features/profile_screen.dart';
import 'features/password_security_screen.dart';
import 'features/notifications_screen.dart';
import 'features/privacy_policy_screen.dart';
import 'features/terms_of_service_screen.dart';
import 'features/test/memory_test_screen.dart'; // Import the memory test screen
import 'config/api_config.dart'; // Import the API config
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await APIConfig.listModels();
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
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const HomeScreen(),
            '/chatbot': (context) => const ChatScreen(),
            '/achievements': (context) => const LeaderboardScreen(),
            '/settings': (context) => const SettingsScreen(),

            // Settings sub-screens
            '/help_center': (context) => const HelpCenterScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/password_security': (context) => const PasswordSecurityScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/privacy_policy': (context) => const PrivacyPolicyScreen(),
            '/terms': (context) => const TermsOfServiceScreen(),
            '/test-memories': (context) => const MemoryTestScreen(),
          },
        );
      },
    );
  }
}
