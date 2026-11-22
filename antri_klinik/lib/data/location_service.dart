import 'package:geolocator/geolocator.dart';

class DeviceLocationResult {
  const DeviceLocationResult({
    required this.latitude,
    required this.longitude,
    required this.distanceToClinicKm,
    required this.isFallbackLocation,
    this.permissionMessage,
  });

  final double latitude;
  final double longitude;
  final double distanceToClinicKm;
  final bool isFallbackLocation;
  final String? permissionMessage;
}

class LocationService {
  // Koordinat Klinik Gigi (Denpasar, Bali)
  static const double clinicLat = -8.6500;
  static const double clinicLon = 115.2167;

  Future<DeviceLocationResult> getCurrentLocationOrFallback() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallback('GPS perangkat tidak aktif. Menggunakan lokasi default Klinik.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _fallback('Izin lokasi ditolak. Menggunakan lokasi area Denpasar sebagai alternatif.');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5), 
        ),
      );
      final meters = Geolocator.distanceBetween(pos.latitude, pos.longitude, clinicLat, clinicLon);

      return DeviceLocationResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        distanceToClinicKm: double.parse((meters / 1000).toStringAsFixed(1)),
        isFallbackLocation: false,
      );
    } catch (_) {
      return _fallback('Gagal membaca sensor GPS. Menggunakan lokasi area Denpasar.');
    }
  }

  DeviceLocationResult _fallback(String reason) {
    return DeviceLocationResult(
      latitude: clinicLat,
      longitude: clinicLon,
      distanceToClinicKm: 0.0,
      isFallbackLocation: true,
      permissionMessage: reason,
    );
  }
}
