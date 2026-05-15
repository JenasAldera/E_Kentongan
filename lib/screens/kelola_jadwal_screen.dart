import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/jadwal_model.dart';

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
      appBar: AppBar(title: const Text('Kelola Jadwal Ronda')),
      body: StreamBuilder<List<JadwalModel>>(
        stream: _firestoreService.getJadwal(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var listJadwal = snapshot.data!;
          return ListView.builder(
            itemCount: listJadwal.length,
            itemBuilder: (context, index) {
              var jadwal = listJadwal[index];
              return ListTile(
                title: Text('${jadwal.tanggal} - ${jadwal.namaWarga}'),
                subtitle: Text('${jadwal.jamMulai} - ${jadwal.jamSelesai} @ ${jadwal.posRonda}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showJadwalDialog(jadwal: jadwal)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _firestoreService.deleteJadwal(jadwal.id)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJadwalDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
