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
import 'user_management_screen.dart';
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
      if (mounted) {
        setState(() {
          _currentUser = data;
          _isLoading = false;
        });
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Check-in Berhasil!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('E-Kentongan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConstants.accentColor,
                    child: Icon(Icons.person, size: 40, color: AppConstants.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${_currentUser?.nama ?? 'User'}!',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Role: ${_currentUser?.role == AppConstants.roleKetua ? 'Ketua RT' : 'Warga'}',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Jadwal Ronda Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<JadwalModel>>(
              stream: _firestoreService.getJadwal(),
              builder: (context, jadwalSnapshot) {
                if (!jadwalSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                var allJadwal = jadwalSnapshot.data!;
                String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
                var todayJadwal = allJadwal.where((j) => j.tanggal == today).toList();

                if (todayJadwal.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Tidak ada jadwal untuk hari ini.', textAlign: TextAlign.center),
                  );
                }

                return StreamBuilder<List<CheckInModel>>(
                  stream: _firestoreService.getCheckIns(_currentUser!.uid),
                  builder: (context, checkinSnapshot) {
                    var checkins = checkinSnapshot.data ?? [];
                    var checkedInJadwalIds = checkins.map((c) => c.jadwalId).toSet();

                    return Column(
                      children: todayJadwal.map((jadwal) {
                        bool isAlreadyCheckedIn = checkedInJadwalIds.contains(jadwal.id);
                        bool isMyJadwal = jadwal.userId == _currentUser?.uid;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(jadwal.namaWarga, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${jadwal.jamMulai} - ${jadwal.jamSelesai} @ ${jadwal.posRonda}'),
                            trailing: isMyJadwal
                                ? (isAlreadyCheckedIn
                                    ? const Chip(
                                        label: Text('Selesai', style: TextStyle(color: Colors.white)),
                                        backgroundColor: Colors.green,
                                      )
                                    : ElevatedButton(
                                        onPressed: () => _checkIn(jadwal.id),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppConstants.primaryColor,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Absen'),
                                      ))
                                : null,
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Menu Utama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildMenuCard(context, Icons.report_problem, 'Laporan', Colors.orange, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LaporanScreen()));
                }),
                if (_currentUser?.role == AppConstants.roleKetua) ...[
                  _buildMenuCard(context, Icons.calendar_month, 'Kelola Jadwal', Colors.blue, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const KelolaJadwalScreen()));
                  }),
                  _buildMenuCard(context, Icons.people, 'Daftar Warga', Colors.teal, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserManagementScreen()));
                  }),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
