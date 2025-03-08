import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game.dart'; // Imports game-related widgets and functionality

//------------------------------------------------------------------------------
// APP ENTRY POINT AND CONFIGURATION
//------------------------------------------------------------------------------

/// Application entry point
void main() {
  // Ensure Flutter binding is initialized before calling other platform methods
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Configure status bar to be transparent with light icons
  // This creates a more immersive game experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Launch the app with the root widget
  runApp(const PathFinderApp());
}

/// Root application widget
/// Sets up theming and navigation for the entire app
class PathFinderApp extends StatelessWidget {
  const PathFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Path Finder', // App name displayed in task switchers

      // Define app-wide theme settings
      theme: ThemeData(
        // Primary color used throughout the app for main elements
        primaryColor: const Color(0xFF0D3445),

        // Background color for scaffold widgets (screens)
        scaffoldBackgroundColor: const Color(0xFF0D3445),

        // Generate a complete color scheme from the seed color
        // Using a dark theme for better contrast with game elements
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3445),
          brightness: Brightness.dark,
        ),

        // Adjust visual density based on the platform
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Set the initial screen to be displayed when app launches
      home: const StartScreen(),
    );
  }
}
