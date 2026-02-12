import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/ble_service.dart';
import '../../services/auth_service.dart';
import '../sos/sos_escalation_screen.dart';
import '../ble/ble_paired_screen.dart'; // ✅ ADD THIS

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BleService _bleService = BleService();
  final AuthService _authService = AuthService();

  StreamSubscription? _sosSub;
  Timer? _bleRetryTimer;

  bool _sosInProgress = false;
  bool _permissionsRequested = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestBlePermissions();
    });

    _startBleFailSafeListener();
  }

  /* ================= PERMISSIONS ================= */

  Future<void> _requestBlePermissions() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;

    final scan = await Permission.bluetoothScan.request();
    final connect = await Permission.bluetoothConnect.request();
    final location = await Permission.locationWhenInUse.request();

    if (!mounted) return;

    if (scan.isDenied || connect.isDenied || location.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bluetooth & location permissions are required for bracelet SOS.',
          ),
        ),
      );
    }
  }

  /* ================= BLE FAIL‑SAFE ================= */

  void _startBleFailSafeListener() {
    _bleRetryTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!mounted) return;

        if (_bleService.isSosReady && _sosSub == null) {
          _startListeningForBraceletSos();
        }
      },
    );
  }

  void _startListeningForBraceletSos() {
    _sosSub = _bleService.listenForSos().listen((_) {
      if (!mounted || _sosInProgress) return;

      _navigateToSos('bracelet');
    });
  }

  void _navigateToSos(String triggeredBy) {
    if (_sosInProgress) return;

    _sosInProgress = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SosEscalationScreen(
          triggeredBy: triggeredBy,
        ),
      ),
    ).then((_) {
      _sosInProgress = false;
    });
  }

  @override
  void dispose() {
    _sosSub?.cancel();
    _bleRetryTimer?.cancel();
    super.dispose();
  }

  /* ================= LOGOUT ================= */

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _authService.signOut();
    }
  }

  /* ================= UI ================= */

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
              _sosButton(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _confirmLogout,
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= HEADER ================= */

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
        children: [
          const Text('SIGTREK', style: TextStyle(fontSize: 18)),

          // ✅ Bluetooth icon now clickable
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BlePairedScreen(),
                ),
              );
            },
            child: const Icon(Icons.bluetooth),
          ),
        ],
      ),
    );
  }

  /* ================= STATUS ================= */

  Widget _braceletStatus() {
    final ready = _bleService.isSosReady;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text(
            'Bracelet Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Connection: ${ready ? 'Connected' : 'Not Connected'}',
          ),
          const Text('Battery: --'),
        ],
      ),
    );
  }

  /* ================= SOS BUTTON ================= */

  Widget _sosButton() {
    return GestureDetector(
      onTap: () {
        _navigateToSos('mobile');
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
