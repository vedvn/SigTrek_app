import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/ble_service.dart';

class BlePairedScreen extends StatelessWidget {
  const BlePairedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = BleService();

    return Scaffold(
      appBar: AppBar(title: const Text('Pair Bracelet')),
      body: StreamBuilder<ScanResult>(
        stream: ble.scan(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          final device = result.device;

          return ListTile(
            title: Text(device.platformName.isEmpty
                ? 'Unknown Device'
                : device.platformName),
            subtitle: Text(device.remoteId.toString()),
            onTap: () async {
              await ble.stopScan();
              await ble.connect(device);
              if (context.mounted) Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
