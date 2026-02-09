import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SOSService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference _sosRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('sos');

  /// Called AFTER 8s escalation
  static Future<String> activateSOS() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await _sosRef(user.uid).add({
      'status': 'active',
      'startedAt': DateTime.now().toIso8601String(),
      'lastLocation': null,
    });

    return doc.id;
  }

  static Future<void> stopSOS({
    required String uid,
    required String sosId,
  }) async {
    await _sosRef(uid).doc(sosId).update({
      'status': 'ended',
      'endedAt': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateLocation({
    required String uid,
    required String sosId,
    required double lat,
    required double lng,
  }) async {
    await _sosRef(uid).doc(sosId).update({
      'lastLocation': {
        'lat': lat,
        'lng': lng,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    });
  }

}
