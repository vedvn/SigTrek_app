import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../services/sos_service.dart';
import 'sos_active_screen.dart';

class SosEscalationScreen extends StatefulWidget {
  const SosEscalationScreen({super.key});

  @override
  State<SosEscalationScreen> createState() => _SosEscalationScreenState();
}

class _SosEscalationScreenState extends State<SosEscalationScreen> {
  int _seconds = 8;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_seconds == 0) {
        timer.cancel();

        // ✅ Activate SOS in Firestore
        final sosId = await SOSService.activateSOS();

        if (!mounted) return;

        // ✅ Go to active SOS screen with sosId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SOSActiveScreen(sosId: sosId),
          ),
        );
        return;
      }

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 500);
      }

      setState(() => _seconds--);
    });
  }

  void _cancelSOS() {
    _timer?.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SOS will activate in',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              '$_seconds',
              style: const TextStyle(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
              onPressed: _cancelSOS,
              child: const Text('Cancel SOS'),
            ),
          ],
        ),
      ),
    );
  }
}
