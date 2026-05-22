import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121214), // Deep Obsidian Dark
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Logo Graphic
            GlowingLogo(),
            SizedBox(height: 24),
            Text(
              'SOCIETY CONNECT',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Smart Complaint Portal',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white38,
              ),
            ),
            SizedBox(height: 48),
            SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)), // Indigo glow
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlowingLogo extends StatelessWidget {
  const GlowingLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.domain_rounded,
          size: 40,
          color: Color(0xFF6366F1),
        ),
      ),
    );
  }
}
