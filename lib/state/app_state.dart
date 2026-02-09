import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AppState {
  final AuthService _authService = AuthService();

  Stream<User?> get authStream => _authService.authStateChanges;

  User? get user => _authService.currentUser;
}
