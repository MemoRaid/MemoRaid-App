import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final Function(int) onTap;
  const CustomBottomNavigationBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFF0D3445), // Ensure the color is applied here
      selectedItemColor: const Color.fromARGB(255, 3, 3, 3),
      unselectedItemColor: Color(0xFF0D3445),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: "Progress Graph",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble),
          label: "AI Chatbot",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rocket_launch),
          label: "Rocket",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: "Achievements",
        ),
      ],
      onTap: onTap,
    );
  }
}
