import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
              "Terms of Service",
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
              child: Column(
                children: [
                  _buildSection(
                    "Last Updated: March 15, 2024",
                    "Please read these terms of service carefully before using MemoRaid.",
                    themeProvider,
                  ),
                  _buildSection(
                    "1. Acceptance of Terms",
                    "By accessing or using MemoRaid, you agree to be bound by these Terms of Service and all applicable laws and regulations.",
                    themeProvider,
                  ),
                  _buildSection(
                    "2. User Account",
                    "• You must provide accurate information when creating an account\n"
                        "• You are responsible for maintaining account security\n"
                        "• You must be at least 13 years old to use this service\n"
                        "• One person may only create one account",
                    themeProvider,
                  ),
                  _buildSection(
                    "3. User Content",
                    "• You retain ownership of your content\n"
                        "• You grant us license to use your content\n"
                        "• You must not upload illegal or harmful content\n"
                        "• We may remove content that violates our policies",
                    themeProvider,
                  ),
                  _buildSection(
                    "4. Intellectual Property",
                    "• MemoRaid and its content are protected by copyright\n"
                        "• You may not copy or distribute our content\n"
                        "• All trademarks belong to their respective owners",
                    themeProvider,
                  ),
                  _buildSection(
                    "5. Privacy",
                    "Your use of MemoRaid is also governed by our Privacy Policy. Please review our Privacy Policy to understand our practices.",
                    themeProvider,
                  ),
                  _buildSection(
                    "6. Termination",
                    "We reserve the right to terminate or suspend your account at our sole discretion, without notice, for conduct that we believe violates these Terms of Service.",
                    themeProvider,
                  ),
                  _buildSection(
                    "7. Changes to Terms",
                    "We may update these terms at any time. Continued use of MemoRaid after changes means you accept the new terms.",
                    themeProvider,
                  ),
                  _buildSection(
                    "8. Contact Us",
                    "If you have any questions about these Terms, please contact us at:\nsupport@memoraid.com",
                    themeProvider,
                  ),
                  SizedBox(height: 20),
                  _buildAcceptButton(context, themeProvider),
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
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
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

  Widget _buildAcceptButton(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terms of Service accepted'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
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
        child: Text(
          'I Accept the Terms of Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
