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
import 'config/api_config.dart';

// Import Code1 auth files
import 'features/loginorsignup.dart';
import 'features/login.dart';
import 'features/signup.dart';
import 'features/verification_screen.dart';
import 'features/share_link.dart';
import 'services/auth_service.dart';

// Ad screens from Code2
import 'features/ad1.dart';
import 'features/ad2.dart';
import 'features/ad3.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await APIConfig.listModels();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (_) => AuthService()), // Add AuthService provider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize auth service when app starts
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.init();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MemoRaid',
          theme: themeProvider.getTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),

            // Auth routes from Code1
            '/login_or_signup': (context) => const LoginSignupScreen(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/verification': (context) => const VerificationScreen(email: ''),

            // Onboarding flow
            '/ad1': (context) => const AdScreen(),
            '/ad2': (context) => const AdScreen2(),
            '/ad3': (context) => const AdScreen3(),
            '/share_link': (context) => const ShareLinkScreen(),

            // Code2 existing routes
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
          },
        );
      },
    );
  }
}
