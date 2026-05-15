import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/jadwal_model.dart';
import '../models/user_model.dart';

class KelolaJadwalScreen extends StatefulWidget {
  const KelolaJadwalScreen({super.key});

  @override
  _KelolaJadwalScreenState createState() => _KelolaJadwalScreenState();
}

class _KelolaJadwalScreenState extends State<KelolaJadwalScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    var users = await _firestoreService.getAllUsers();
    setState(() {
      _allUsers = users;
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _showJadwalDialog({JadwalModel? jadwal}) {
    final tanggalController = TextEditingController(text: jadwal?.tanggal ?? '');
    final jamMulaiController = TextEditingController(text: jadwal?.jamMulai ?? '');
    final jamSelesaiController = TextEditingController(text: jadwal?.jamSelesai ?? '');
    final posRondaController = TextEditingController(text: jadwal?.posRonda ?? '');

    UserModel? selectedUser;
    if (jadwal != null) {
      try {
        selectedUser = _allUsers.firstWhere((u) => u.uid == jadwal.userId);
      } catch (_) {}
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tanggalController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    await _selectDate(context, tanggalController);
                    setDialogState(() {});
                  },
                ),
                TextField(
                  controller: jamMulaiController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Jam Mulai',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    await _selectTime(context, jamMulaiController);
                    setDialogState(() {});
                  },
                ),
                TextField(
                  controller: jamSelesaiController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Jam Selesai',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    await _selectTime(context, jamSelesaiController);
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<UserModel>(
                  value: selectedUser,
                  hint: const Text('Pilih Warga'),
                  items: _allUsers.map((user) {
                    return DropdownMenuItem(
                      value: user,
                      child: Text(user.nama),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedUser = val;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Petugas Ronda'),
                ),
                TextField(controller: posRondaController, decoration: const InputDecoration(labelText: 'Pos Ronda')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (selectedUser == null || tanggalController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi data terlebih dahulu!')));
                  return;
                }

                JadwalModel newJadwal = JadwalModel(
                  id: jadwal?.id ?? '',
                  tanggal: tanggalController.text,
                  jamMulai: jamMulaiController.text,
                  jamSelesai: jamSelesaiController.text,
                  namaWarga: selectedUser!.nama,
                  userId: selectedUser!.uid,
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
