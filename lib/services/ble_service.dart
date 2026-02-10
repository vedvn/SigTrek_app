import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? sosCharacteristic;

  /// UUIDs MUST match bracelet firmware
  static const String SOS_SERVICE_UUID =
      "0000fff0-0000-1000-8000-00805f9b34fb";
  static const String SOS_CHAR_UUID =
      "0000fff1-0000-1000-8000-00805f9b34fb";

  /* ================= SCAN ================= */

  Stream<ScanResult> scan() {
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 6),
    );
    return FlutterBluePlus.scanResults.expand((r) => r);
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /* ================= CONNECT ================= */

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(
      license: License.free,
      autoConnect: false,
    );

    connectedDevice = device;

    // Reset old state
    sosCharacteristic = null;

    await _discoverServices(device);

    // 🔐 Auto‑cleanup on disconnect
    device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        debugPrint('⚠️ Bracelet disconnected');
        connectedDevice = null;
        sosCharacteristic = null;
      }
    });
  }

  Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    connectedDevice = null;
    sosCharacteristic = null;
  }

  /* ================= DISCOVER ================= */

  Future<void> _discoverServices(BluetoothDevice device) async {
    final services = await device.discoverServices();

    for (final service in services) {
      if (service.uuid.toString().toLowerCase() ==
          SOS_SERVICE_UUID.toLowerCase()) {
        for (final char in service.characteristics) {
          if (char.uuid.toString().toLowerCase() ==
              SOS_CHAR_UUID.toLowerCase()) {
            sosCharacteristic = char;

            if (char.properties.notify) {
              await char.setNotifyValue(true);
            }

            debugPrint(
              '✅ SOS characteristic ready (notify=${char.properties.notify})',
            );
            return;
          }
        }
      }
    }

    debugPrint(
      '⚠️ SOS service/characteristic NOT found on device ${device.remoteId}',
    );
  }

  /* ================= SOS LISTENER ================= */

  /// Emits an event ONLY when bracelet sends SOS = 1
  /// NEVER throws — safe to call anytime
  Stream<void> listenForSos() {
    final char = sosCharacteristic;

    if (char == null) {
      debugPrint('⚠️ listenForSos: SOS characteristic not ready');
      return const Stream.empty();
    }

    return char.value
        .where((data) => data.isNotEmpty && data.first == 1)
        .map((_) => null);
  }

  /* ================= STATUS ================= */

  /// True only when bracelet + SOS characteristic are ready
  bool get isSosReady =>
      connectedDevice != null && sosCharacteristic != null;
}
