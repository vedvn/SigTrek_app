import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/ble_service.dart';
import '../sos/sos_escalation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _bleService = BleService();
  StreamSubscription? _sosSub;
  bool _sosInProgress = false;

  @override
  void initState() {
    super.initState();

    _sosSub = _bleService.listenForSos().listen((_) {
      if (!mounted) return;
      if (_sosInProgress) return;

      _sosInProgress = true;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SosEscalationScreen(
            triggeredBy: 'bracelet',
          ),
        ),
      ).then((_) {
        _sosInProgress = false;
      });
    });
  }

  @override
  void dispose() {
    _sosSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 40),
              _braceletStatus(),
              const Spacer(),
              _sosButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('SIGTREK', style: TextStyle(fontSize: 18)),
          Icon(Icons.bluetooth),
        ],
      ),
    );
  }

  Widget _braceletStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        children: [
          Text(
            'Bracelet Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Connection: Not Connected'),
          Text('Battery: --'),
        ],
      ),
    );
  }

  Widget _sosButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SosEscalationScreen(
              triggeredBy: 'mobile',
            ),
          ),
        );
      },
      child: Container(
        width: 220,
        height: 220,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'SOS',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
