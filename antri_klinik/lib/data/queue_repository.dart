import '../models/queue_status.dart';
import 'api_client.dart';
import 'location_service.dart';

abstract class QueueRepository {
  Future<QueueTicket> takeQueueTicket(String patientName, int currentServing);
}

class RemoteQueueRepository implements QueueRepository {
  RemoteQueueRepository(this._api, this._locationService);

  final ApiClient _api;
  final LocationService _locationService;
  String? lastLocationWarning;

  @override
  Future<QueueTicket> takeQueueTicket(String patientName, int currentServing) async {
    // 1. Ambil lokasi dari device GPS
    final loc = await _locationService.getCurrentLocationOrFallback();
    lastLocationWarning = loc.permissionMessage;

    // 2. Panggil API Cuaca berdasarkan koordinat GPS pasien
    final weatherUri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${loc.latitude}',
      'longitude': '${loc.longitude}',
      'current': 'temperature_2m,weather_code',
    });
    final weatherJson = await _api.getJson(weatherUri);
    final weather = WeatherInfo.fromOpenMeteoJson(weatherJson);

    // 3. Kirim tiket antrean beserta data lokasi & cuaca ke REST API
    final ticketUri = Uri.https('jsonplaceholder.typicode.com', '/posts');
    final ticketJson = await _api.postJson(ticketUri, {
      'title': patientName,
      'body': 'Lat:${loc.latitude}, Lon:${loc.longitude}, Cuaca:${weather.description}',
      'userId': 1,
    });

    // Simulasi nomor tiket berurutan (misal 4 antrean di depan pasien)
    final simulatedTicket = currentServing + 4;
    return QueueTicket.fromApiJson(
      {...ticketJson, 'id': simulatedTicket},
      currentServing: currentServing,
      distanceKm: loc.distanceToClinicKm,
      weather: weather,
    );
  }
}
