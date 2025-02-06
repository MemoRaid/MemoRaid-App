import 'package:flutter/material.dart';
import 'authentication/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen size
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255)
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: -width * 0.01, // Adjust based on screen size
              top: -height * 0.01, // Adjust based on screen size
              child: Container(
                width: width * 0.9981, // Set width to full screen width
                height: height *
                    1.01, // Set height to a proportion of the screen height
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("lib/assets/images/splash.png"),
                    fit: BoxFit.cover, // Ensures the image scales properly
                  ),
                ),
              ),
            ),
            Positioned(
              left: width * 0.05, // Adjust for responsiveness
              top: height * 0.8, // Adjust vertical position
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Container(
                  width: width * 0.9, // Make width relative
                  height: height * 0.06, // Adjust height based on screen size
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 02),
                  decoration: ShapeDecoration(
                    color: Color(0xFF0D3445),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
