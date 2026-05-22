import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onEnterDemoMode;

  const ErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onEnterDemoMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214), // Deep Obsidian Dark
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Warning Icon
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 38,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Database Sync Offline',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We could not establish a real-time connection to Firebase Firestore. Please check your network connection or Firebase credentials.',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      color: Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Retry Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: const Text(
                      'RETRY CONNECTION',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1), // Indigo
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Enter Demo Mode Escape Hatch
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onEnterDemoMode,
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text(
                      'ENTER OFFLINE DEMO MODE',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981), // Emerald green
                      side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
