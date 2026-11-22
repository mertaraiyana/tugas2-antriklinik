import 'package:flutter_test/flutter_test.dart';
import 'package:antri_klinik/data/api_exception.dart';
import 'package:antri_klinik/data/queue_repository.dart';
import 'package:antri_klinik/models/queue_status.dart';
import 'package:antri_klinik/ui/queue_view_model.dart';

class FakeQueueRepository implements QueueRepository {
  bool shouldFail = false;

  @override
  Future<QueueTicket> takeQueueTicket(String patientName, int currentServing) async {
    if (shouldFail) {
      throw const ApiException(ApiErrorKind.noConnection, 'Offline');
    }
    return QueueTicket(
      ticketNumber: currentServing + 3,
      currentServing: currentServing,
      patientName: patientName,
      distanceKm: 2.5,
      weather: const WeatherInfo(temperature: 28.0, weatherCode: 61),
    );
  }
}

void main() {
  test('Berhasil mengambil antrean dan memicu status tinggal 3 nomor lagi', () async {
    final repo = FakeQueueRepository();
    final vm = QueueViewModel(repo);

    await vm.bookQueue('Ayu');

    expect(vm.state, isA<Success<QueueTicket>>());
    final ticket = (vm.state as Success<QueueTicket>).data;
    expect(ticket.remainingQueues, 3);
    expect(ticket.isAlmostTurn, isTrue);
    expect(ticket.weather.isRaining, isTrue);
  });

  test('Menampilkan Failure saat API gagal terhubung', () async {
    final repo = FakeQueueRepository()..shouldFail = true;
    final vm = QueueViewModel(repo);

    await vm.bookQueue('Ayu');

    expect(vm.state, isA<Failure<QueueTicket>>());
  });
}
