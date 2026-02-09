import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _users =>
      _firestore.collection('users');

  /// Create profile ONLY if it doesn't exist
  Future<void> createUserProfileIfNotExists(User user) async {
    final docRef = _users.doc(user.uid);
    final doc = await docRef.get();

    if (doc.exists) return;

    await docRef.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
      'isProfileComplete': false,
      'emergencyContactsCount': 0,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> isProfileComplete(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc['isProfileComplete'] == true;
  }

  Future<int> emergencyContactsCount(String uid) async {
    final doc = await _users.doc(uid).get();
    return doc['emergencyContactsCount'] ?? 0;
  }

  Future<Map<String, dynamic>> getProfileStatus(String uid) async {
    final doc = await _users.doc(uid).get();

    if (!doc.exists) {
      return {
        'profileComplete': false,
        'emergencyContactsCount': 0,
      };
    }

    final data = doc.data() as Map<String, dynamic>;

    return {
      'profileComplete': data['isProfileComplete'] == true,
      'emergencyContactsCount': data['emergencyContactsCount'] ?? 0,
    };
  }

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
