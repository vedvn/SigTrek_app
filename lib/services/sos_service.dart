import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SOSService {
  static final _firestore = FirebaseFirestore.instance;

  static CollectionReference _sosRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('sos');

  /// 🔴 Called AFTER 8s escalation
  static Future<String> activateSOS({
    required String triggeredBy,
    required String locationSource,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final doc = await _sosRef(user.uid).add({
      'status': 'active',
      'triggeredBy': triggeredBy,
      'locationSource': locationSource,
      'startedAt': FieldValue.serverTimestamp(),
      'lastLocation': null,
    });

    return doc.id;
  }

  /// 🛑 Stop SOS
  static Future<void> stopSOS({
    required String uid,
    required String sosId,
  }) async {
    await _sosRef(uid).doc(sosId).update({
      'status': 'ended',
      'endedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 📍 Update location every 5 seconds
  static Future<void> updateLocation({
    required String uid,
    required String sosId,
    required double lat,
    required double lng,
  }) async {
    final sosDoc = _sosRef(uid).doc(sosId);

    final locationData = {
      'lat': lat,
      'lng': lng,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // ✅ Update last location (quick access)
    await sosDoc.update({
      'lastLocation': locationData,
    });

    // ✅ Store history in subcollection (for tracking map / timeline)
    await sosDoc.collection('locations').add(locationData);
  }
}
