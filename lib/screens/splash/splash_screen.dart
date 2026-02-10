import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/profile_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/profile_setup_screen.dart';
import '../onboarding/emergency_contact_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }

        return _PostAuthRouter(user: user);
      },
    );
  }
}

class _PostAuthRouter extends StatelessWidget {
  final User user;
  final ProfileService _profileService = ProfileService();

  _PostAuthRouter({required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _profileService.getProfileStatus(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? {};

        final bool profileComplete =
            (data['profileComplete'] as bool?) ?? false;
        final int contactsCount =
            (data['emergencyContactsCount'] as int?) ?? 0;

        if (!profileComplete) {
          return const ProfileSetupScreen();
        }

        if (contactsCount == 0) {
          return const EmergencyContactScreen();
        }

        return const HomeScreen();
      },
    );
  }
}
