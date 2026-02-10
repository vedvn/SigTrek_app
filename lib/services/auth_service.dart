import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'profile_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  // ⚠️ Works reliably with google_sign_in ^6.x
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /* ================= AUTH STATE ================= */

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /* ================= EMAIL SIGN UP ================= */

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _profileService.createUserProfileIfNotExists(
      user: credential.user!,
      authProvider: 'email',
    );

    return credential;
  }

  /* ================= EMAIL SIGN IN (+ LINKING) ================= */

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
    AuthCredential? pendingCredential, // 👈 used for linking
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 🔗 Link Google credential if present
    if (pendingCredential != null) {
      await credential.user!
          .linkWithCredential(pendingCredential);
    }

    await _profileService.createUserProfileIfNotExists(
      user: credential.user!,
      authProvider: 'email',
    );

    return credential;
  }

  /* ================= GOOGLE SIGN IN (+ LINKING) ================= */

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final googleCredential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    try {
      // Normal Google sign-in
      final userCredential =
          await _auth.signInWithCredential(googleCredential);

      await _profileService.createUserProfileIfNotExists(
        user: userCredential.user!,
        authProvider: 'google',
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // 🚨 Email already exists → needs linking
        await _handleAccountLinking(e, googleCredential);
        return null;
      }
      rethrow;
    }
  }

  /* ================= ACCOUNT LINKING HANDLER ================= */

Future<void> _handleAccountLinking(
  FirebaseAuthException e,
  AuthCredential googleCredential,
) async {
  final email = e.email;
  if (email == null) {
    throw Exception('Email not available for account linking');
  }

  // 🔔 We already KNOW the account exists
  // FirebaseAuth 6.x no longer exposes fetchSignInMethodsForEmail
  // So we simply ask user to login with email & password

  throw FirebaseAuthException(
    code: 'linking-required',
    message:
        'Please login with email & password to link your Google account.',
    credential: googleCredential,
  );
}


  /* ================= SIGN OUT ================= */

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

}
