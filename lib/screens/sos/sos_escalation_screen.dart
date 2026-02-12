import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import '../../services/sos_service.dart';
import '../../services/foreground_service.dart';
import 'sos_active_screen.dart';

class SosEscalationScreen extends StatefulWidget {
  final String triggeredBy;

  const SosEscalationScreen({
    super.key,
    required this.triggeredBy,
  });

  @override
  State<SosEscalationScreen> createState() => _SosEscalationScreenState();
}

class _SosEscalationScreenState extends State<SosEscalationScreen> {
  int _seconds = 8;
  Timer? _timer;
  bool _serviceStarted = false;

  @override
  void initState() {
    super.initState();
    _initSosFlow();
  }

  Future<void> _initSosFlow() async {
    try {
      // ✅ Request notification permission first
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // ✅ Start foreground service safely
      await SosForegroundService.start();
      _serviceStarted = true;

      _startCountdown();
    } catch (e) {
      debugPrint("SOS Init Error: $e");
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_seconds == 0) {
        timer.cancel();

        if (_serviceStarted) {
          await SosForegroundService.stop();
        }

        final sosId = await SOSService.activateSOS(
          triggeredBy: widget.triggeredBy,
          locationSource:
              widget.triggeredBy == 'bracelet' ? 'bracelet' : 'mobile',
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SOSActiveScreen(sosId: sosId),
          ),
        );
        return;
      }

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 300);
      }

      if (mounted) {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _cancelSOS() async {
    _timer?.cancel();

    if (_serviceStarted) {
      await SosForegroundService.stop();
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();

    if (_serviceStarted) {
      SosForegroundService.stop();
    }

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
