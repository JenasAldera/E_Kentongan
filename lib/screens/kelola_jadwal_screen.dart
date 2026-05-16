import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/jadwal_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

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
    if (mounted) {
      setState(() {
        _allUsers = users;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
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
    if (picked != null && mounted) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(jadwal == null ? 'Tambah Jadwal' : 'Edit Jadwal', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: tanggalController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Pilih Tanggal',
                    suffixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onTap: () async {
                    await _selectDate(context, tanggalController);
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 16),
                const Text('Jam Mulai', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: jamMulaiController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Pilih Jam',
                    suffixIcon: const Icon(Icons.access_time),
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onTap: () async {
                    await _selectTime(context, jamMulaiController);
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 16),
                const Text('Jam Selesai', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: jamSelesaiController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Pilih Jam',
                    suffixIcon: const Icon(Icons.access_time),
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onTap: () async {
                    await _selectTime(context, jamSelesaiController);
                    setDialogState(() {});
                  },
                ),
                const SizedBox(height: 16),
                const Text('Pilih Warga', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserModel>(
                  value: selectedUser,
                  items: _allUsers.map((user) {
                    return DropdownMenuItem(value: user, child: Text(user.nama));
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      selectedUser = val;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pos Ronda', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: posRondaController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Pos RT 01',
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (selectedUser == null || tanggalController.text.isEmpty) return;
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
                if (mounted) Navigator.pop(context);
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
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Kelola Jadwal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: StreamBuilder<List<JadwalModel>>(
        stream: _firestoreService.getJadwal(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var listJadwal = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listJadwal.length,
            itemBuilder: (context, index) {
              var jadwal = listJadwal[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text('${jadwal.tanggal} - ${jadwal.namaWarga}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${jadwal.jamMulai} - ${jadwal.jamSelesai} @ ${jadwal.posRonda}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blue), onPressed: () => _showJadwalDialog(jadwal: jadwal)),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _firestoreService.deleteJadwal(jadwal.id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () => _showJadwalDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
