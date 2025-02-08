import 'package:flutter/material.dart';

class AdScreen2 extends StatelessWidget {
  const AdScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.20, 0.98),
            end: Alignment(0.2, -0.98),
            colors: [Colors.white],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 95,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 646,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/sendmoney.png',
                      width: 221.16,
                      height: 260,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17.5),
                      child: Text(
                        'Track Your Progress and Watch Your Skills Grow Over Time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF2A2A2A),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/adscreen3');
                      },
                      child: Container(
                        width: 330,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D3445),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
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
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 37,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 16,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D3445),
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 37,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
