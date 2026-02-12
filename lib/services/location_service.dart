import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Ensure GPS + permission
  static Future<void> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }
  }

  static Stream<Position> positionStream() {
    final androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
      intervalDuration: const Duration(seconds: 5),
      forceLocationManager: false,
    );

    return Geolocator.getPositionStream(
      locationSettings: androidSettings,
    );
  }
}
