import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/ble_service.dart';

class BlePairedScreen extends StatefulWidget {
  const BlePairedScreen({super.key});

  @override
  State<BlePairedScreen> createState() => _BlePairedScreenState();
}

class _BlePairedScreenState extends State<BlePairedScreen> {
  final BleService _ble = BleService();
  final List<ScanResult> _results = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    _ble.scan().listen((result) {
      final exists = _results.any(
        (r) => r.device.remoteId == result.device.remoteId,
      );

      if (!exists) {
        setState(() {
          _results.add(result);
        });
      }
    });
  }

  @override
  void dispose() {
    _ble.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pair Bracelet')),
      body: _results.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final device = _results[index].device;

                return ListTile(
                  title: Text(
                    device.platformName.isEmpty
                        ? 'Unknown Device'
                        : device.platformName,
                  ),
                  subtitle: Text(device.remoteId.toString()),
                  trailing: const Icon(Icons.bluetooth),
                  onTap: () async {
                    await _ble.stopScan();
                    await _ble.connect(device);

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
    );
  }
}
