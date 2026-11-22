import 'package:flutter/foundation.dart';
import '../data/api_exception.dart';
import '../data/queue_repository.dart';
import '../models/queue_status.dart';

sealed class UiState<T> {
  const UiState();
}

class Idle<T> extends UiState<T> {
  const Idle();
}

class Loading<T> extends UiState<T> {
  const Loading();
}

class Success<T> extends UiState<T> {
  const Success(this.data);
  final T data;
}

class Failure<T> extends UiState<T> {
  const Failure(this.message);
  final String message;
}

class QueueViewModel extends ChangeNotifier {
  QueueViewModel(this._repository);

  final QueueRepository _repository;

  int _currentServing = 101;
  int get currentServing => _currentServing;

  UiState<QueueTicket> _state = const Idle();
  UiState<QueueTicket> get state => _state;

  String? get locationWarning =>
      _repository is RemoteQueueRepository ? _repository.lastLocationWarning : null;

  Future<void> bookQueue(String patientName) async {
    if (patientName.trim().isEmpty) {
      _state = const Failure('Nama pasien tidak boleh kosong.');
      notifyListeners();
      return;
    }
    _state = const Loading();
    notifyListeners();

    try {
      final ticket = await _repository.takeQueueTicket(
        patientName.trim(),
        _currentServing,
      );
      _state = Success(ticket);
    } on ApiException catch (e) {
      _state = Failure(e.message);
    } catch (e) {
      _state = Failure('Terjadi kesalahan tak terduga: $e');
    }
    notifyListeners();
  }

  void callNextPatient() {
    _currentServing++;
    if (_state case Success(:final data)) {
      _state = Success(
        QueueTicket(
          ticketNumber: data.ticketNumber,
          currentServing: _currentServing,
          patientName: data.patientName,
          distanceKm: data.distanceKm,
          weather: data.weather,
        ),
      );
    }
    notifyListeners();
  }
}
