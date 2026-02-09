import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import '../../services/sos_service.dart';

class SOSActiveScreen extends StatefulWidget {
  final String sosId;

  const SOSActiveScreen({
    super.key,
    required this.sosId,
  });

  @override
  State<SOSActiveScreen> createState() => _SOSActiveScreenState();
}

class _SOSActiveScreenState extends State<SOSActiveScreen> {
  StreamSubscription<Position>? _positionSub;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  Future<void> _startTracking() async {
    await LocationService.ensurePermission();

    _positionSub =
        LocationService.positionStream().listen((position) {
      SOSService.updateLocation(
        uid: _uid,
        sosId: widget.sosId,
        lat: position.latitude,
        lng: position.longitude,
      );
    });
  }

  Future<void> _stopSOS() async {
    await SOSService.stopSOS(
      uid: _uid,
      sosId: widget.sosId,
    );

    await _positionSub?.cancel();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade800,
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        title: const Text('SOS ACTIVE'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.white, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Live location sharing',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
              onPressed: _stopSOS,
              child: const Text('STOP SOS'),
            ),
          ],
        ),
      ),
    );
  }
}
