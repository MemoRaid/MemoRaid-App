import 'package:flutter/material.dart';

class AnalyticsScreen extends StatelessWidget {
  final int totalSeconds;
  final int cycles;

  const AnalyticsScreen({
    super.key,
    required this.totalSeconds,
    required this.cycles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D3445),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Breathing Analytics",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Epilogue',
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Analytics Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    "🕒 Duration: ${totalSeconds ~/ 60} min ${totalSeconds % 60} sec",
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "🌬️ Total Breath Cycles: $cycles",
                    style: const TextStyle(fontSize: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Additional Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "💡 Regular breathing exercises can improve oxygen flow, reduce stress, and enhance memory retention for individuals with amnesia.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
