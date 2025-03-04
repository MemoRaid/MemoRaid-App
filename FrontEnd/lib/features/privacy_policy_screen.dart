import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Scaffold(
          backgroundColor: themeProvider.primaryBackgroundColor,
          appBar: AppBar(
            backgroundColor: themeProvider.primaryBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon:
                  Icon(Icons.arrow_back, color: themeProvider.primaryTextColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Privacy Policy",
              style: TextStyle(
                color: themeProvider.primaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: themeProvider.getGradientColors(),
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: 16), // Add consistent horizontal padding
              child: Column(
                children: [
                  SizedBox(height: 16), // Add top padding
                  _buildSection(
                    "Last Updated: March 15, 2024",
                    "Welcome to MemoRaid's Privacy Policy. This document explains how we collect, use, and protect your personal information.",
                    themeProvider,
                  ),
                  _buildSection(
                    "Information We Collect",
                    "• Personal Information (name, email, profile picture)\n"
                        "• Usage Data (app interactions, progress metrics)\n"
                        "• Device Information (device type, OS version)\n"
                        "• Performance Data (memory training results)",
                    themeProvider,
                  ),
                  _buildSection(
                    "How We Use Your Information",
                    "• Personalize your experience\n"
                        "• Improve memory training algorithms\n"
                        "• Track your progress and achievements\n"
                        "• Send important updates and notifications",
                    themeProvider,
                  ),
                  _buildSection(
                    "Data Protection",
                    "We implement industry-standard security measures to protect your personal information from unauthorized access, disclosure, or misuse.",
                    themeProvider,
                  ),
                  _buildSection(
                    "Your Rights",
                    "• Access your personal data\n"
                        "• Request data correction\n"
                        "• Delete your account\n"
                        "• Opt-out of communications",
                    themeProvider,
                  ),
                  _buildSection(
                    "Third-Party Services",
                    "We may use third-party services for analytics and improvements. These services have their own privacy policies.",
                    themeProvider,
                  ),
                  _buildSection(
                    "Updates to Policy",
                    "We may update this policy periodically. We will notify you of any significant changes.",
                    themeProvider,
                  ),
                  _buildSection(
                    "Contact Us",
                    "If you have questions about this privacy policy, please contact us at:\nsupport@memoraid.com",
                    themeProvider,
                  ),
                  SizedBox(height: 20),
                  _buildContactButton(context, themeProvider),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
      String title, String content, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity, // Ensure full width
      margin: EdgeInsets.only(bottom: 16), // Consistent vertical spacing
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF0D3445),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
      BuildContext context, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity, // Ensure full width
      child: ElevatedButton.icon(
        icon: Icon(Icons.email_outlined),
        label: Text('Contact Privacy Team'),
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.accentColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          minimumSize: Size(double.infinity, 55),
        ),
        onPressed: () {
          // Implement email functionality here
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening email client...'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}
