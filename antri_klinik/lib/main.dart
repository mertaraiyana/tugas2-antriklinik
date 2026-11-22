import 'package:flutter/material.dart';
import 'data/api_client.dart';
import 'data/location_service.dart';
import 'data/queue_repository.dart';
import 'models/queue_status.dart';
import 'ui/queue_view_model.dart';

void main() {
  final repo = RemoteQueueRepository(ApiClient(), LocationService());
  final viewModel = QueueViewModel(repo);
  runApp(AntriKlinikApp(viewModel: viewModel));
}

class AntriKlinikApp extends StatelessWidget {
  const AntriKlinikApp({super.key, required this.viewModel});
  final QueueViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AntriKlinik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: QueueHomeView(viewModel: viewModel),
    );
  }
}

class QueueHomeView extends StatefulWidget {
  const QueueHomeView({super.key, required this.viewModel});
  final QueueViewModel viewModel;

  @override
  State<QueueHomeView> createState() => _QueueHomeViewState();
}

class _QueueHomeViewState extends State<QueueHomeView> {
  final _nameController = TextEditingController(text: 'Budi Santoso');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AntriKlinik Gigi'),
        actions: [
          TextButton.icon(
            onPressed: vm.callNextPatient,
            icon: const Icon(Icons.campaign),
            label: const Text('Panggil Berikutnya'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: vm,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card Status Klinik Real-time
              Card(
                color: Colors.teal.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Nomor Sedang Dilayani', style: TextStyle(fontSize: 16)),
                      Text(
                        'A-${vm.currentServing}',
                        style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      const Text('Jam Operasional: 08.00 – 20.00 WITA'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Form Ambil Antrean
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Pasien',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: vm.state is Loading ? null : () => vm.bookQueue(_nameController.text),
                icon: const Icon(Icons.my_location),
                label: const Text('Ambil Nomor Antrean (Cek GPS & Cuaca)'),
              ),
              const SizedBox(height: 20),
              // State Handling: Loading / Failure / Success
              switch (vm.state) {
                Idle() => const Center(
                    child: Text('Tekan tombol di atas untuk mengambil nomor antrean.'),
                  ),
                Loading() => const Center(child: CircularProgressIndicator()),
                Failure(:final message) => Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(message, style: TextStyle(color: Colors.red.shade900)),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => vm.bookQueue(_nameController.text),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                Success(:final data) => _TicketResultCard(
                    ticket: data,
                    locationWarning: vm.locationWarning,
                  ),
              },
            ],
          );
        },
      ),
    );
  }
}

class _TicketResultCard extends StatelessWidget {
  const _TicketResultCard({required this.ticket, this.locationWarning});
  final QueueTicket ticket;
  final String? locationWarning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (locationWarning != null)
          Card(
            color: Colors.amber.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text('⚠️ $locationWarning'),
            ),
          ),
        if (ticket.isAlmostTurn || ticket.isMyTurn)
          Card(
            color: Colors.orange.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                ticket.isMyTurn
                    ? '🔔 GILIRAN ANDA SEKARANG! Silakan masuk ke ruang periksa.'
                    : '🔔 BERSIAP! Giliran Anda tinggal ${ticket.remainingQueues} nomor lagi.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tiket Anda: A-${ticket.ticketNumber}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('Pasien: ${ticket.patientName}'),
                Text('Sisa antrean di depan: ${ticket.remainingQueues} orang'),
                const Divider(height: 24),
                Text('📍 Jarak GPS ke Klinik: ${ticket.distanceKm} km'),
                Text('🌤️ Cuaca di Lokasi Anda: ${ticket.weather.description} (${ticket.weather.temperature}°C)'),
                if (ticket.weather.isRaining)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text(
                      '💡 Saran: Terdeteksi hujan di lokasi GPS Anda, berangkatlah 10 menit lebih awal.',
                      style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
