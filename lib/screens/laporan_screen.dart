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
      setState(() {
        _currentUser = data;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan Terkirim')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Kejadian')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _teksController,
                    decoration: const InputDecoration(hintText: 'Tulis laporan kejadian...'),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _kirimLaporan),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<LaporanModel>>(
              stream: _firestoreService.getLaporan(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var laporanList = snapshot.data!;
                return ListView.builder(
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    var lapor = laporanList[index];
                    return ListTile(
                      title: Text(lapor.teks),
                      subtitle: Text('${lapor.namaWarga} - ${DateFormat('dd MMM yyyy HH:mm').format(lapor.timestamp)}'),
                      trailing: (_currentUser?.role == AppConstants.roleKetua)
                          ? IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _firestoreService.deleteLaporan(lapor.id);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan Dihapus')));
                              },
                            )
                          : null,
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
