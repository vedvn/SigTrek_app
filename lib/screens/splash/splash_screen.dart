import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/profile_setup_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // ⚠️ TEMPORARY: we’ll add Firestore profile check next
        return const ProfileSetupScreen();
      },
    );
  }
}
