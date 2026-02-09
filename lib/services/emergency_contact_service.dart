import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _contactsRef(String uid) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('emergency_contacts');

  /// CREATE
  Future<void> addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    await _contactsRef(user.uid).add({
      'name': name,
      'phone': phone,
      'relation': relation,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await _updateCount(user.uid);
  }

  /// READ (stream)
  Stream<QuerySnapshot> contactsStream() {
    final user = FirebaseAuth.instance.currentUser!;
    return _contactsRef(user.uid).snapshots();
  }

  /// UPDATE
  Future<void> updateContact({
    required String contactId,
    required String name,
    required String phone,
    required String relation,
  }) async {
    final user = FirebaseAuth.instance.currentUser!;
    await _contactsRef(user.uid).doc(contactId).update({
      'name': name,
      'phone': phone,
      'relation': relation,
    });
  }

  /// DELETE
  Future<void> deleteContact(String contactId) async {
    final user = FirebaseAuth.instance.currentUser!;
    await _contactsRef(user.uid).doc(contactId).delete();
    await _updateCount(user.uid);
  }

  /// Update counter in user profile
  Future<void> _updateCount(String uid) async {
    final snapshot = await _contactsRef(uid).get();
    await _firestore.collection('users').doc(uid).update({
      'emergencyContactsCount': snapshot.size,
    });
  }
}
