import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onTap;
  const CustomBottomNavigationBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0D3445),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
      type: BottomNavigationBarType.fixed, // Prevent shifting animation
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progress"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), label: "AI Chatbot"),
        BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch), label: "Rocket"),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: "Achievements"),
      ],
      onTap: onTap,
    );
  }
}
