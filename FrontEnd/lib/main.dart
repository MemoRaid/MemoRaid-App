import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/note.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
//import 'features/test/memory_test_screen.dart'; // Import the memory test screen
// Import Code1 auth files
import 'memoraid_features/auth/loginorsignup.dart';
import 'memoraid_features/auth/login.dart';
import 'memoraid_features/auth/signup.dart';
import 'memoraid_features/auth/verification_screen.dart';
import 'memoraid_features/auth/share_link.dart';
import 'memoraid_features/services/auth_service.dart';

// Ad screens from Code2
import 'features/ad1.dart';
import 'features/ad2.dart';
import 'features/ad3.dart';

void main() async {
  // Initialize Flutter bindings first
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

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
            '/progress': (context) => const LeaderboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/notebook': (context) => const TaskSchedulerScreen(),

            // Settings sub-screens
            '/help_center': (context) => const HelpCenterScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/password_security': (context) => const PasswordSecurityScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/privacy_policy': (context) => const PrivacyPolicyScreen(),
            '/terms': (context) => const TermsOfServiceScreen(),
//'/test-memories': (context) => const MemoryTestScreen(),
          },
        );
      },
    );
  }
}
