import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.20, 0.98),
            end: Alignment(0.2, -0.98),
            colors: [Colors.white],
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Stack(
          children: [
            // Header Bar
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 360,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 51.56),
                    const Text(
                      '9:41',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1F2024),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.17,
                        fontFamily: 'SF Pro Text',
                      ),
                    ),
                    const SizedBox(width: 68),
                  ],
                ),
              ),
            ),

            // Logo
            Positioned(
              left: 118.5,
              top: 5,
              child: Container(
                width: 122,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Center(child: FlutterLogo(size: 30)),
              ),
            ),

            // Terms and Conditions Title
            Positioned(
              left: 19,
              top: 50,
              child: Container(
                width: 320,
                height: 56,
                padding: const EdgeInsets.symmetric(vertical: 19.5),
                color: Colors.white,
                child: const Center(
                  child: Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),

            // Welcome Message
            Positioned(
              left: 20,
              top: 122,
              child: SizedBox(
                width: 320,
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Welcome to ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const TextSpan(
                        text: 'MemoRaid',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const TextSpan(
                        text:
                            '! By utilizing our app, you accept these terms and conditions. Please ensure you read them thoroughly before you begin.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Terms Content
            Positioned(
              left: 20,
              top: 180,
              child: SizedBox(
                width: 320,
                height: 874,
                child: SingleChildScrollView(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        sectionTitle('1. About MemoRaid'),
                        sectionBody(
                            'MemoRaid is an application designed to assist individuals facing memory challenges, such as amnesia. Our goal is to facilitate an enjoyable memory management experience through features like cognitive games, reminders, journals, and caregiver support.'),
                        sectionTitle('2. Who Can Use the App?'),
                        sectionBody(
                            'You must be at least 13 years of age to utilize MemoRaid. If you are under 18, please seek consent from a parent or guardian.'),
                        sectionTitle('3. Your Account'),
                        sectionBody(
                            'You are responsible for maintaining the security of your account information. Do not share your password with anyone. If you detect any suspicious activity in your account, please inform us immediately.'),
                        sectionTitle('4. What You Can’t Do'),
                        sectionBody(
                            'Do not use MemoRaid to violate any laws. Please do not misuse the application or attempt to hack it. Do not upload any inappropriate, harmful, or offensive materials.'),
                        sectionTitle('5. Data and Privacy'),
                        sectionBody(
                            'We only collect the information necessary to deliver our services (such as reminders and health tracking). We do not sell your personal information to other parties. For further details, please review our Privacy Policy.'),
                        sectionTitle('6. Content Ownership'),
                        sectionBody(
                            'The material you input into the app (e.g., journal entries) belongs to you. MemoRaid retains ownership of the app’s design, features, and other content. You are not permitted to replicate or distribute any part of the app without authorization.'),
                        sectionTitle('7. Using the App Safely'),
                        sectionBody(
                            'MemoRaid is a tool for memory support, but it should not replace professional medical advice. Always consult a healthcare provider for significant health or memory concerns.'),
                        sectionTitle('8. Updates'),
                        sectionBody(
                            'We may release updates to enhance the app or add new features. These updates may require you to download the latest version.'),
                        sectionTitle('9. Termination'),
                        sectionBody(
                            'You may discontinue your use of the app at any time. We reserve the right to suspend or terminate your account if you breach these terms.'),
                        sectionTitle('10. Limitation of Liability'),
                        sectionBody(
                            'At MemoRaid, we strive to offer a dependable and helpful application to assist your memory recovery journey. While we make every effort to ensure the app operates smoothly, there may be occasional issues beyond our control.'),
                        sectionTitle('11. Changes to These Terms'),
                        sectionBody(
                            'We may revise these terms in the future. If that occurs, we will notify you through the app.'),
                        sectionTitle('12. Contact Us'),
                        sectionBody(
                            'If you have any inquiries regarding these terms, please reach out to us.'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Agree & Continue Button
            Positioned(
              left: 15,
              top: 1058,
              child: Container(
                width: 330,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF0D3445),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Center(
                  child: Text(
                    'Agree & Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Indicator Bar
            Positioned(
              left: 113,
              top: 1144,
              child: Container(
                width: 133,
                height: 6,
                decoration: BoxDecoration(
                  color: Color(0xFF1F2024),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan sectionTitle(String title) {
    return TextSpan(
      text: '$title\n',
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 10,
        fontFamily: 'Inter',
        color: Colors.black,
      ),
    );
  }

  TextSpan sectionBody(String body) {
    return TextSpan(
      text: '$body\n\n',
      style: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 10,
        fontFamily: 'Inter',
        color: Colors.black,
      ),
    );
  }
}
