import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import 'login_screen.dart';

// Pure Dart Code - Welcome Screen after login
class WelcomeScreen extends StatefulWidget {
  final String userName;
  final String userRole;

  const WelcomeScreen({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to dashboard after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateToDashboard();
      }
    });
  }

  void _navigateToDashboard() {
    final role = widget.userRole.toUpperCase();
    if (role == 'ADMIN' || role == 'OWNER') {
      // Navigate to shop dashboard
      Navigator.of(context).pushReplacementNamed('/shop-dashboard');
    } else {
      // Navigate to user dashboard
      Navigator.of(context).pushReplacementNamed('/user-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6200EE),
              Color(0xFF3700B3),
              Color(0xFF03DAC6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              const Icon(
                Icons.store,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              
              // Welcome Text
              Text(
                'Welcome, ${widget.userName}! 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

