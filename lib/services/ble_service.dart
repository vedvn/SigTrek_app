import 'dart:async';
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
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
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
    await _discoverServices(device);
  }



  Future<void> disconnect() async {
    await connectedDevice?.disconnect();
    connectedDevice = null;
  }

  /* ================= DISCOVER ================= */

  Future<void> _discoverServices(BluetoothDevice device) async {
    final services = await device.discoverServices();

    for (final service in services) {
      if (service.uuid.toString() == SOS_SERVICE_UUID) {
        for (final char in service.characteristics) {
          if (char.uuid.toString() == SOS_CHAR_UUID) {
            sosCharacteristic = char;
            await char.setNotifyValue(true);
          }
        }
      }
    }
  }

  /* ================= SOS LISTENER ================= */

  Stream<void> listenForSos() {
    if (sosCharacteristic == null) {
      throw Exception('SOS characteristic not found');
    }

    return sosCharacteristic!.value.map((data) {
      if (data.isNotEmpty && data[0] == 1) {
        return;
      }
    });
  }

  bool get isConnected => connectedDevice != null;
}
