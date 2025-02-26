import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.onTap,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0D3445),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Progress"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble), label: "AI Chatbot"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: "Achievements"),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/progress');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/chatbot');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/settings');
            break;
          case 4:
            Navigator.pushReplacementNamed(context, '/achievements');
            break;
        }
        onTap(index);
      },
    );
  }
}
