import 'package:flutter/material.dart';

class AdFeaturePage extends StatelessWidget {
  const AdFeaturePage({super.key});

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
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 44,
                child: Center(
                  child: Text(
                    '9:41',
                    style: TextStyle(
                      color: Color(0xFF1F2024),
                      fontSize: 15,
                      fontFamily: 'SF Pro Text',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.17,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 95,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      width: 181.92,
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage('assets/images/Trust.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 88),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        'Rebuild Memory with Engaging, Science-Backed Exercises',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF2A2A2A),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.71,
                        ),
                      ),
                    ),
                    SizedBox(height: 71),
                    GestureDetector(
                      onTap: () {
                        // Action when "Next" is tapped
                      },
                      child: Container(
                        width: 330,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Color(0xFF0D3445),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 34,
                padding: const EdgeInsets.only(
                  top: 21,
                  left: 121,
                  right: 120,
                  bottom: 8,
                ),
                child: Center(
                  child: Container(
                    width: 134,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFF1F2024),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ensure you have added the image in your assets folder as 'assets/images/Trust.png'
// Also, update your pubspec.yaml file with the following:
// flutter:

//     - assets/images/Trust.png
