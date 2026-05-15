import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/jadwal_model.dart';
import '../models/checkin_model.dart';
import '../utils/constants.dart';
import 'laporan_screen.dart';
import 'kelola_jadwal_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var data = await _authService.getUserData(user.uid);
      setState(() {
        _currentUser = data;
        _isLoading = false;
      });
    }
  }

  void _checkIn(String jadwalId) async {
    if (_currentUser != null) {
      CheckInModel checkIn = CheckInModel(
        id: '',
        jadwalId: jadwalId,
        userId: _currentUser!.uid,
        namaWarga: _currentUser!.nama,
        waktu: DateTime.now(),
      );
      await _firestoreService.checkIn(checkIn);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in Berhasil!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Kentongan Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, ${_currentUser?.nama ?? 'User'}!', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            const Text('Jadwal Ronda Hari Ini:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder<List<JadwalModel>>(
              stream: _firestoreService.getJadwal(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var allJadwal = snapshot.data!;
                String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                var todayJadwal = allJadwal.where((j) => j.tanggal == today).toList();

                if (todayJadwal.isEmpty) return const Text('Tidak ada jadwal untuk hari ini.');

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayJadwal.length,
                  itemBuilder: (context, index) {
                    var jadwal = todayJadwal[index];
                    return Card(
                      child: ListTile(
                        title: Text(jadwal.namaWarga),
                        subtitle: Text('${jadwal.jamMulai} - ${jadwal.jamSelesai} @ ${jadwal.posRonda}'),
                        trailing: jadwal.userId == _currentUser?.uid
                            ? ElevatedButton(onPressed: () => _checkIn(jadwal.id), child: const Text('Check-In'))
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuButton(context, Icons.report, 'Laporan', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LaporanScreen()));
                }),
                if (_currentUser?.role == AppConstants.roleKetua)
                  _buildMenuButton(context, Icons.admin_panel_settings, 'Kelola Jadwal', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const KelolaJadwalScreen()));
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
    );
  }
}
