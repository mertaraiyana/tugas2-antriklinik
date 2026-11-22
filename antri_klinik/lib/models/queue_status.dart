class WeatherInfo {
  const WeatherInfo({
    required this.temperature,
    required this.weatherCode,
  });

  final double temperature;
  final int weatherCode;

  bool get isRaining => weatherCode >= 51 && weatherCode <= 99;

  String get description {
    if (weatherCode == 0) return 'Cerah';
    if (weatherCode <= 3) return 'Cerah Berawan';
    if (weatherCode >= 51 && weatherCode <= 67) return 'Hujan / Gerimis';
    if (weatherCode >= 80) return 'Hujan Lebat / Badai';
    return 'Berawan';
  }

  factory WeatherInfo.fromOpenMeteoJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherInfo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
    );
  }
}

class QueueTicket {
  const QueueTicket({
    required this.ticketNumber,
    required this.currentServing,
    required this.patientName,
    required this.distanceKm,
    required this.weather,
  });

  final int ticketNumber;
  final int currentServing;
  final String patientName;
  final double distanceKm;
  final WeatherInfo weather;

  int get remainingQueues => (ticketNumber - currentServing).clamp(0, 999);
  bool get isAlmostTurn => remainingQueues > 0 && remainingQueues <= 3;
  bool get isMyTurn => ticketNumber == currentServing;

  factory QueueTicket.fromApiJson(
    Map<String, dynamic> ticketJson, {
    required int currentServing,
    required double distanceKm,
    required WeatherInfo weather,
  }) {
    return QueueTicket(
      ticketNumber: (ticketJson['id'] as num?)?.toInt() ?? 104,
      currentServing: currentServing,
      patientName: ticketJson['title'] as String? ?? 'Pasien',
      distanceKm: distanceKm,
      weather: weather,
    );
  }
}
