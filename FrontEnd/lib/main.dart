import 'package:flutter/material.dart';
import 'features/splash.dart'; // Import your splash screen

void main() {
  runApp(MyApp());
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
        // Global BottomNavigationBar theme customization
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor:
              Color(0xFF0D3445), // Global background color for BottomNavBar
          selectedItemColor:
              Color.fromARGB(255, 3, 3, 3), // Selected item color
          unselectedItemColor: Color(0xFF0D3445), // Unselected item color
        ),
      ),
      home: SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}
