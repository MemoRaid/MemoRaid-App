import 'package:flutter/material.dart';

class AdFeaturePage2 extends StatelessWidget {
  const AdFeaturePage2({super.key});

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
                padding: const EdgeInsets.only(
                  top: 14,
                  left: 19.10,
                  right: 14,
                  bottom: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      child: Text(
                        '9:41',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF1F2024),
                          fontSize: 15,
                          fontFamily: 'SF Pro Text',
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.17,
                        ),
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 14,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '􀛨',
                            style: TextStyle(
                              color: Color(0xFF1F2024),
                              fontSize: 17,
                              fontFamily: 'SF Pro Text',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '􀙇',
                            style: TextStyle(
                              color: Color(0xFF1F2024),
                              fontSize: 14,
                              fontFamily: 'SF Pro Text',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Container(
                            width: 17.10,
                            height: 10.70,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/sendmoney.png"), // Updated to AssetImage
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 118.50,
              top: 5,
              child: Container(
                width: 122,
                height: 36,
                decoration: ShapeDecoration(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: FlutterLogo(),
              ),
            ),
            Positioned(
              left: 0,
              top: 95,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 646,
                child: Column(
                  children: [
                    Container(
                      width: 221.16,
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Image.asset(
                              'assets/images/sendmoney.png', // Updated to Image.asset
                              width: 221.16,
                              height: 260,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 89),
                    Transform(
                      transform: Matrix4.identity()
                        ..translate(0.0, 0.0)
                        ..rotateZ(3.14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 37,
                            height: 8,
                            decoration: ShapeDecoration(
                              color: Color(0xFFD0D0D0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 16,
                            height: 8,
                            decoration: ShapeDecoration(
                              color: Color(0xFF0D3445),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 37,
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
                    SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17.50),
                      child: Text(
                        'Track Your Progress and Watch Your Skills Grow Over Time.',
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
                    SizedBox(height: 72),
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
