import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/jadwal_model.dart';
import '../utils/constants.dart';

class KelolaJadwalScreen extends StatefulWidget {
  const KelolaJadwalScreen({super.key});

  @override
  _KelolaJadwalScreenState createState() => _KelolaJadwalScreenState();
}

class _KelolaJadwalScreenState extends State<KelolaJadwalScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _showJadwalDialog({JadwalModel? jadwal}) {
    final tanggalController = TextEditingController(text: jadwal?.tanggal ?? '');
    final jamMulaiController = TextEditingController(text: jadwal?.jamMulai ?? '');
    final jamSelesaiController = TextEditingController(text: jadwal?.jamSelesai ?? '');
    final namaWargaController = TextEditingController(text: jadwal?.namaWarga ?? '');
    final userIdController = TextEditingController(text: jadwal?.userId ?? '');
    final posRondaController = TextEditingController(text: jadwal?.posRonda ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: tanggalController, decoration: const InputDecoration(labelText: 'Tanggal (YYYY-MM-DD)')),
              TextField(controller: jamMulaiController, decoration: const InputDecoration(labelText: 'Jam Mulai')),
              TextField(controller: jamSelesaiController, decoration: const InputDecoration(labelText: 'Jam Selesai')),
              TextField(controller: namaWargaController, decoration: const InputDecoration(labelText: 'Nama Warga')),
              TextField(controller: userIdController, decoration: const InputDecoration(labelText: 'User ID Warga')),
              TextField(controller: posRondaController, decoration: const InputDecoration(labelText: 'Pos Ronda')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              JadwalModel newJadwal = JadwalModel(
                id: jadwal?.id ?? '',
                tanggal: tanggalController.text,
                jamMulai: jamMulaiController.text,
                jamSelesai: jamSelesaiController.text,
                namaWarga: namaWargaController.text,
                userId: userIdController.text,
                posRonda: posRondaController.text,
              );

              if (jadwal == null) {
                await _firestoreService.addJadwal(newJadwal);
              } else {
                await _firestoreService.updateJadwal(newJadwal);
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kelola Jadwal Ronda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textColor),
            ),
            const Text(
              'Atur dan pantau jadwal petugas keamanan lingkungan mendatang.',
              style: TextStyle(fontSize: 14, color: AppConstants.mutedTextColor),
            ),
            const SizedBox(height: 24),
            StreamBuilder<List<JadwalModel>>(
              stream: _firestoreService.getJadwal(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var listJadwal = snapshot.data!;
                return Column(
                  children: [
                    ...listJadwal.map((jadwal) => _buildJadwalCard(jadwal)).toList(),
                    const SizedBox(height: 16),
                    _buildSummaryCard(listJadwal.length),
                  ],
                );
              },
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJadwalDialog(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildJadwalCard(JadwalModel jadwal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                jadwal.tanggal.toUpperCase(),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.mutedTextColor),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showJadwalDialog(jadwal: jadwal),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _firestoreService.deleteJadwal(jadwal.id),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
                      child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            jadwal.namaWarga,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppConstants.mutedTextColor),
              const SizedBox(width: 4),
              Text(
                '${jadwal.jamMulai} - ${jadwal.jamSelesai} WIB',
                style: const TextStyle(color: AppConstants.mutedTextColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildPersonChip(jadwal.namaWarga),
              _buildPersonChip('Bpk. Budi'), // Placeholder for additional members if model supported it
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 14, color: AppConstants.mutedTextColor),
          const SizedBox(width: 4),
          Text(name, style: const TextStyle(fontSize: 12, color: AppConstants.textColor)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Jadwal', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('$total Hari', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Menampilkan jadwal untuk periode mendatang.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.calendar_today_outlined, color: Colors.white24, size: 60),
        ],
      ),
    );
  }
}
