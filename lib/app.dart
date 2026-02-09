import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

class SigTrekApp extends StatelessWidget {
  const SigTrekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        // 🔄 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // ❌ Error state
        if (snapshot.hasError) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text('Firebase initialization failed'),
              ),
            ),
          );
        }

        // ✅ Firebase ready → run app
        return MaterialApp(
          title: 'SigTrek',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppRouter.splash,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
