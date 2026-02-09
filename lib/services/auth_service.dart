import 'package:firebase_auth/firebase_auth.dart';
import 'profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  /// Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /* ================= EMAIL AUTH ================= */

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
    );

  await _profileService.createUserProfileIfNotExists(
    credential.user!,
  );

  return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /* ================= GOOGLE AUTH (LATEST & CORRECT) ================= */

  Future<UserCredential> signInWithGoogle() async {
  final googleProvider = GoogleAuthProvider();

  final credential =
      await _auth.signInWithProvider(googleProvider);

  await _profileService.createUserProfileIfNotExists(
    credential.user!,
  );

  return credential;
}


  /* ================= SIGN OUT ================= */

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
