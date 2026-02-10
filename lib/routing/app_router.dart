import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/onboarding/emergency_contact_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/ble/ble_paired_screen.dart';
import '../screens/sos/sos_active_screen.dart';

class AppRouter {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const profileSetup = '/profile-setup';
  static const emergencyContact = '/emergency-contact';
  static const home = '/home';
  static const blePaired = '/ble-paired';
  static const sosActive = '/sos-active';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case profileSetup:
        return MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        );

      case emergencyContact:
        return MaterialPageRoute(
          builder: (_) => const EmergencyContactScreen(),
        );

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case blePaired:
        return MaterialPageRoute(builder: (_) => const BlePairedScreen());

      case sosActive:
        final args = settings.arguments;

        if (args == null || args is! String) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('Invalid or missing SOS ID'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => SOSActiveScreen(sosId: args),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
