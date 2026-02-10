import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /* ================= CREATE / UPDATE ================= */

  /// Create user profile if it does NOT exist
  /// Safe to call after any login (email / google)
  Future<void> createUserProfileIfNotExists({
    required User user,
    required String authProvider, // 'email' | 'google'
  }) async {
    final docRef = _users.doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) {
      // Ensure authProvider exists even for old users
      await docRef.set(
        {
          'authProvider': authProvider,
        },
        SetOptions(merge: true),
      );
      return;
    }

    await docRef.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
      'authProvider': authProvider,
      'isProfileComplete': false,
      'emergencyContactsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /* ================= READ HELPERS ================= */

  Future<bool> isProfileComplete(String uid) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data();
    if (data == null) return false;
    return data['isProfileComplete'] == true;
  }

  Future<int> emergencyContactsCount(String uid) async {
    final doc = await _users.doc(uid).get();
    final data = doc.data();
    if (data == null) return 0;
    return (data['emergencyContactsCount'] as int?) ?? 0;
  }

  /// Used by SplashScreen
  Future<Map<String, dynamic>> getProfileStatus(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return {
        'profileComplete': false,
        'emergencyContactsCount': 0,
      };
    }

    final data = doc.data()!;

    return {
      'profileComplete': data['isProfileComplete'] == true,
      'emergencyContactsCount':
          (data['emergencyContactsCount'] as int?) ?? 0,
    };
  }

  /* ================= UPDATE ================= */

  Future<void> markProfileComplete({
    required String uid,
    required String name,
  }) async {
    await _users.doc(uid).update({
      'name': name,
      'isProfileComplete': true,
    });
  }
}
