import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.19, 0.98),
              end: Alignment(0.19, -0.98),
              colors: [Color(0x7F0D3445), Colors.white, Colors.white],
            ),
          ),
          child: Column(
            children: [
              // Header without Dynamic Island
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // User Profile Section
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFEAF2FF),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0xFF264857),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Lucas Scott',
                      style: TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.08,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '@lucasscott3',
                      style: TextStyle(
                        color: Color(0xFF71727A),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.12,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Options
              buildSettingsOption('Profile', context),
              buildSettingsOption('Appearance', context),
              buildSettingsOption('Password', context),
              buildSettingsOption('Personal Data', context),
              buildSettingsOption('Help Center', context),
              buildSettingsOption('Chat with Us', context),
              buildSettingsOption('Privacy & Security', context),
              buildSettingsOption('Terms of Service', context),
              buildSettingsOption('Log Out', context),

              // Bottom Indicator Bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D8D8),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingsOption(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(1.00, 0.00),
            end: Alignment(-1, 0),
            colors: [Color(0xFFD9D9D9), Color(0xFF508298)],
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Color(0xFF0D3445),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF021219)),
          ],
        ),
      ),
    );
  }
}
