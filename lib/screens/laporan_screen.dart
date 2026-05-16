import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../models/laporan_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  _LaporanScreenState createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final _teksController = TextEditingController();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var data = await _authService.getUserData(user.uid);
      if (mounted) {
        setState(() {
          _currentUser = data;
        });
      }
    }
  }

  void _kirimLaporan() async {
    if (_teksController.text.isNotEmpty && _currentUser != null) {
      LaporanModel laporan = LaporanModel(
        id: '',
        userId: _currentUser!.uid,
        namaWarga: _currentUser!.nama,
        teks: _teksController.text,
        timestamp: DateTime.now(),
      );
      await _firestoreService.addLaporan(laporan);
      _teksController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan Terkirim')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Laporan Kejadian', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20.0),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teksController,
                    decoration: InputDecoration(
                      hintText: 'Tulis laporan kejadian...',
                      filled: true,
                      fillColor: AppConstants.backgroundColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppConstants.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _kirimLaporan,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<LaporanModel>>(
              stream: _firestoreService.getLaporan(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var laporanList = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    var lapor = laporanList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(lapor.teks, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${lapor.namaWarga} - ${DateFormat('dd MMM yyyy HH:mm').format(lapor.timestamp)}'),
                        trailing: (_currentUser?.role == AppConstants.roleKetua)
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  await _firestoreService.deleteLaporan(lapor.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan Dihapus')));
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
