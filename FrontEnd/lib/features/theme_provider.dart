import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Load saved theme preference
  _loadThemeFromPrefs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preferences: $e');
    }
  }

  // Toggle theme and save preference
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notify first for immediate UI update

    try {
      // Save to preferences after updating state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      print('Error saving theme preferences: $e');
    }
  }

  // Get the appropriate theme based on isDarkMode
  ThemeData getTheme() {
    return _isDarkMode ? _darkTheme : _lightTheme;
  }

  // Get colors for gradients and custom UI elements based on theme
  Color get primaryBackgroundColor =>
      _isDarkMode ? Color(0xFF121212) : Colors.white;
  Color get secondaryBackgroundColor => Color(0xFF0D3445);
  Color get cardColor => _isDarkMode ? Color(0xFF1E1E1E) : Color(0xFF0D3445);
  Color get primaryTextColor => _isDarkMode ? Colors.white : Color(0xFF0D3445);
  Color get secondaryTextColor => Colors.white;
  Color get accentColor => Color(0xFF4E6077);

  // Function to get gradient colors based on theme
  List<Color> getGradientColors() {
    return _isDarkMode
        ? [Color(0xFF1E1E1E), Color(0xFF0D3445)]
        : [Colors.white, Color(0xFF0D3445)];
  }

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(0xFF0D3445),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF0D3445),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF0D3445),
      secondary: Color(0xFF4E6077),
    ),
  );

  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Color(0xFF0D3445),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF0D3445),
      secondary: Color(0xFF4E6077),
      surface: Color(0xFF1E1E1E),
    ),
  );
}
