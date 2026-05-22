import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/complaint_provider.dart';
import 'views/screens/dashboard_screen.dart';
import 'views/screens/splash_screen.dart';
import 'views/screens/error_screen.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<ComplaintProvider>(
      create: (_) => ComplaintProvider(),
      child: const CommunityAppShell(),
    ),
  );
}

class CommunityAppShell extends StatefulWidget {
  const CommunityAppShell({super.key});

  @override
  State<CommunityAppShell> createState() => _CommunityAppShellState();
}

class _CommunityAppShellState extends State<CommunityAppShell> {
  // Initialization state trackers
  bool _initialized = false;
  bool _error = false;
  String _errorDetails = '';
  bool _offlineMode = true;

  @override
  void initState() {
    super.initState();
    // Start directly in Offline Sandbox mode to prevent background thread crashes on Windows
  }

  // Robust Firebase Initialization & error tracking
  Future<void> _initializeFirebase() async {
    setState(() {
      _initialized = false;
      _error = false;
      _errorDetails = '';
      _offlineMode = false;
    });

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      if (mounted) {
        Provider.of<ComplaintProvider>(context, listen: false).retryConnection();
      }

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _errorDetails = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Complaint Portal',
      debugShowCheckedModeBanner: false,
      
      // Gorgeous, High-Fidelity Dark Obsidian Glass Theme Design
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF121214),
        cardColor: const Color(0xFF1E1E22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366F1), // Glowing indigo
          secondary: Color(0xFF10B981), // Emerald green
          surface: Color(0xFF1E1E22),
          background: Color(0xFF121214),
          error: Color(0xFFEF4444), // Coral red
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Outfit', color: Colors.white70),
          bodyMedium: TextStyle(fontFamily: 'Outfit', color: Colors.white60),
          titleLarge: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold),
        ),
        sliderTheme: const SliderThemeData(
          showValueIndicator: ShowValueIndicator.always,
        ),
      ),
      
      // Dynamic routing / screen flow based on initialization state
      home: _buildHomeState(),
    );
  }

  Widget _buildHomeState() {
    if (_offlineMode) {
      // Offline/Demo mode: bypass firebase initialization and show dashboard
      return const DashboardScreen();
    }

    if (_error) {
      // Edge Case: Connection failure / Setup issue
      return ErrorScreen(
        errorMessage: _errorDetails,
        onRetry: _initializeFirebase,
        onEnterDemoMode: () {
          setState(() {
            _offlineMode = true;
          });
        },
      );
    }

    if (!_initialized) {
      // Perfect Flow: Loading splash
      return const SplashScreen();
    }

    // Success flow: load dashboard
    return const DashboardScreen();
  }
}
