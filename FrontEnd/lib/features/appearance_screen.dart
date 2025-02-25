import 'package:flutter/material.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appearance'),
      ),
      body: Center(
        child: Text('Appearance Screen'),
      ),
    );
  }
}
