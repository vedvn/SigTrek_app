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

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return _PostAuthRouter(user: snapshot.data!);
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileService.getProfileStatus(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profileComplete = snapshot.data!['profileComplete'];
        final contactsCount = snapshot.data!['emergencyContactsCount'];

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
