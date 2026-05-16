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

  Future<void> _selectDate(BuildContext context, TextEditingController controller, StateSetter setDialogState) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setDialogState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller, StateSetter setDialogState) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setDialogState(() {
        controller.text = picked.format(context);
      });
    }
  }

  void _showJadwalDialog({JadwalModel? jadwal}) {
    final reguController = TextEditingController(text: jadwal?.namaRegu ?? '');
    final tanggalController = TextEditingController(text: jadwal?.tanggal ?? '');
    final jamMulaiController = TextEditingController(text: jadwal?.jamMulai ?? '');
    final jamSelesaiController = TextEditingController(text: jadwal?.jamSelesai ?? '');
    final posRondaController = TextEditingController(text: jadwal?.posRonda ?? '');

    List<UserModel> selectedUsers = [];
    if (jadwal != null) {
      selectedUsers = _allUsers.where((u) => jadwal.userIds.contains(u.uid)).toList();
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
                const Text('Nama Regu', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: reguController,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Regu Rajawali',
                    filled: true,
                    fillColor: AppConstants.backgroundColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Pilih Petugas (Bisa lebih dari 1)', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: _allUsers.map((user) {
                      bool isSelected = selectedUsers.any((u) => u.uid == user.uid);
                      return CheckboxListTile(
                        title: Text(user.nama, style: const TextStyle(fontSize: 14)),
                        value: isSelected,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedUsers.add(user);
                            } else {
                              selectedUsers.removeWhere((u) => u.uid == user.uid);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
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
                  onTap: () => _selectDate(context, tanggalController, setDialogState),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mulai', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: jamMulaiController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: '00:00',
                              filled: true,
                              fillColor: AppConstants.backgroundColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onTap: () => _selectTime(context, jamMulaiController, setDialogState),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: jamSelesaiController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: '00:00',
                              filled: true,
                              fillColor: AppConstants.backgroundColor,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onTap: () => _selectTime(context, jamSelesaiController, setDialogState),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Pos Ronda', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: posRondaController,
                  decoration: InputDecoration(
                    hintText: 'Lokasi Pos',
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
                if (selectedUsers.isEmpty || tanggalController.text.isEmpty || reguController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data!')));
                  return;
                }
                JadwalModel newJadwal = JadwalModel(
                  id: jadwal?.id ?? '',
                  namaRegu: reguController.text,
                  tanggal: tanggalController.text,
                  jamMulai: jamMulaiController.text,
                  jamSelesai: jamSelesaiController.text,
                  namaWarga: selectedUsers.map((u) => u.nama).toList(),
                  userIds: selectedUsers.map((u) => u.uid).toList(),
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
      body: StreamBuilder<List<JadwalModel>>(
        stream: _firestoreService.getJadwal(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var listJadwal = snapshot.data!;
          
          // Data for summary
          int totalWarga = _allUsers.length;
          int totalPos = listJadwal.map((j) => j.posRonda).toSet().length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
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

                // List of Jadwal Cards
                ...listJadwal.map((jadwal) => _buildJadwalCard(jadwal)).toList(),
                const SizedBox(height: 24),

                // Summary Cards
                _buildSummaryMain(listJadwal.length),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSmallSummary('PETUGAS AKTIF', '$totalWarga Warga', Icons.people_outline)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSmallSummary('AREA PANTAU', '$totalPos Pos', Icons.location_on_outlined)),
                  ],
                ),
                const SizedBox(height: 80), 
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showJadwalDialog(),
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildJadwalCard(JadwalModel jadwal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getDayName(jadwal.tanggal)}, ${jadwal.tanggal}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.mutedTextColor),
              ),
              Row(
                children: [
                  _buildCircleAction(Icons.edit, Colors.grey[200]!, Colors.black54, () => _showJadwalDialog(jadwal: jadwal)),
                  const SizedBox(width: 8),
                  _buildCircleAction(Icons.delete_outline, const Color(0xFFFFEBEE), Colors.red, () => _firestoreService.deleteJadwal(jadwal.id)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            jadwal.namaRegu,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: AppConstants.mutedTextColor),
              const SizedBox(width: 4),
              Text('${jadwal.jamMulai} - ${jadwal.jamSelesai} WIB', style: const TextStyle(color: AppConstants.mutedTextColor, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: jadwal.namaWarga.map((name) => _buildMemberChip(name)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color bg, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildMemberChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppConstants.backgroundColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 14, color: AppConstants.mutedTextColor),
          const SizedBox(width: 4),
          Text(name, style: const TextStyle(fontSize: 11, color: AppConstants.textColor)),
        ],
      ),
    );
  }

  Widget _buildSummaryMain(int total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TOTAL JADWAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.mutedTextColor)),
              const SizedBox(height: 4),
              Text('$total Hari', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
              const SizedBox(height: 4),
              const Text('Periode Mendatang', style: TextStyle(fontSize: 12, color: AppConstants.mutedTextColor)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppConstants.backgroundColor, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_month, color: AppConstants.primaryColor, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallSummary(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppConstants.mutedTextColor, size: 20),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppConstants.mutedTextColor)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
        ],
      ),
    );
  }

  String _getDayName(String dateStr) {
    try {
      DateTime dt = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('EEEE').format(dt).toUpperCase();
    } catch (e) {
      return 'HARI';
    }
  }
}
