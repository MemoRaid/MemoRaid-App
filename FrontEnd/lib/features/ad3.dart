import 'package:flutter/material.dart';

class AdScreen3 extends StatelessWidget {
  const AdScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF0D3445)),
          onPressed: () {
            Navigator.pop(context); // Navigate back to AdScreen2
          },
        ),
        centerTitle: true,
        title: Text(
          "Ad Screen 3",
          style: TextStyle(color: Color(0xFF0D3445)),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFF0D3445),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Content for AdScreen3
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                children: [
                  // Image and Text for AdScreen3
                  Image.asset("assets/images/receivemoney.png",
                      width: width * 0.8),
                  SizedBox(height: height * 0.03),
                  Text(
                    "Steady Growth: Capture Your Journey.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0D3445),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  // Progress Indicator (Same as previous screens)
                  Container(
                    width: width * 0.6,
                    height: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: (width * 0.35 - 2 * 2) / 3,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFF0D3445),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Container(
                          width: (width * 0.35 - 2 * 2) / 3,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD0D0D0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                        ),
                        SizedBox(width: 2),
                        Container(
                          width: (width * 0.35 - 2 * 2) / 3,
                          height: 8,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD0D0D0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Next Button (Navigate to Feature3Page or AdScreen4)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: GestureDetector(
                onTap: () {
                  // You can modify this to navigate to the next screen (Feature4 or elsewhere)
                },
                child: Container(
                  width: width * 0.9,
                  height: height * 0.06,
                  decoration: ShapeDecoration(
                    color: Color(0xFF0D3445),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Finish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.03),
          ],
        ),
      ),
    );
  }
}
