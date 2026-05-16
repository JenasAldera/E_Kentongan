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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  UserModel? _currentUser;
  bool _isLoading = true;
  int _currentIndex = 0;

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

    final List<Widget> _pages = [
      _buildDashboard(),
      const KelolaJadwalScreen(),
      const LaporanScreen(),
      if (_currentUser?.role == AppConstants.roleKetua) const UserManagementScreen(),
    ];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _currentIndex == 0 ? _buildAppBar() : AppBar(
        title: Text(_currentIndex == 1 ? 'Jadwal' : _currentIndex == 2 ? 'Laporan' : 'Warga'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: AppConstants.accentColor,
          child: Text(
            _currentUser?.nama != null && _currentUser!.nama.isNotEmpty 
              ? _currentUser!.nama[0].toUpperCase() 
              : '?',
            style: const TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.notifications_active, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          const Text('E-Kentongan', style: TextStyle(color: AppConstants.textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppConstants.textColor),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: AppConstants.textColor),
          onPressed: () async {
            await _authService.logout();
            if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
        ),
      ],
    );
  }

  Widget _buildDashboard() {
    String greeting = _getGreeting();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: const TextStyle(color: AppConstants.mutedTextColor, fontSize: 16)),
          Text(_currentUser?.nama ?? 'User', style: const TextStyle(color: AppConstants.textColor, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFFC62828)),
                SizedBox(width: 8),
                Text('Status Lingkungan: Kondisi Aman', style: TextStyle(color: Color(0xFFC62828), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildCheckInBanner(),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _buildActionCard('Buat Laporan', 'Insiden & Temuan', Icons.error_outline, Colors.amber, () => setState(() => _currentIndex = 2))),
              const SizedBox(width: 16),
              Expanded(child: _buildActionCard('Lihat Jadwal', 'Satu Minggu Ke Depan', Icons.calendar_today, Colors.amber, () => setState(() => _currentIndex = 1))),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jadwal Ronda Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor)),
              Text(DateFormat('dd MMM yyyy').format(DateTime.now()), style: const TextStyle(color: AppConstants.mutedTextColor, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),

          _buildJadwalList(),
          
          const SizedBox(height: 24),
          _buildSummaryFooter(),
        ],
      ),
    );
  }

  Widget _buildCheckInBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.location_on, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Check-in Sekarang', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Laporkan kehadiran di pos ronda', style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppConstants.mutedTextColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildJadwalList() {
    return StreamBuilder<List<JadwalModel>>(
      stream: _firestoreService.getJadwal(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var allJadwal = snapshot.data!;
        String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        var todayJadwal = allJadwal.where((j) => j.tanggal == today).toList();

        if (todayJadwal.isEmpty) return const Center(child: Text('Tidak ada jadwal hari ini'));

        return StreamBuilder<List<CheckInModel>>(
          stream: _firestoreService.getCheckIns(_currentUser!.uid),
          builder: (context, checkinSnapshot) {
            var checkedInIds = (checkinSnapshot.data ?? []).map((c) => c.jadwalId).toSet();
            return Column(
              children: todayJadwal.map((jadwal) => _buildJadwalCard(jadwal, checkedInIds.contains(jadwal.id))).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildJadwalCard(JadwalModel jadwal, bool isDone) {
    bool isMyJadwal = jadwal.userIds.contains(_currentUser?.uid);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: const Border(left: BorderSide(color: AppConstants.primaryColor, width: 6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(jadwal.namaRegu.toUpperCase(), style: TextStyle(color: AppConstants.primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                if (isMyJadwal) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                  child: const Text('TUGAS ANDA', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: jadwal.namaWarga.map((name) => _buildMemberChip(name)).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppConstants.mutedTextColor),
                const SizedBox(width: 4),
                Text(jadwal.posRonda, style: const TextStyle(color: AppConstants.mutedTextColor, fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: AppConstants.mutedTextColor),
                const SizedBox(width: 4),
                Text('${jadwal.jamMulai} - ${jadwal.jamSelesai}', style: const TextStyle(color: AppConstants.mutedTextColor, fontSize: 13)),
              ],
            ),
            if (isMyJadwal && !isDone) ...[
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _checkIn(jadwal.id),
                  style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Absen Sekarang'),
                ),
              ),
            ] else if (isDone) ...[
               const Divider(height: 24),
               const Center(child: Text('Sudah Absen', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
            ]
          ],
        ),
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

  Widget _buildSummaryFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppConstants.mutedTextColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pos Terpantau', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Sistem keamanan aktif di seluruh titik.', style: TextStyle(color: AppConstants.mutedTextColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    bool isKetua = _currentUser?.role == AppConstants.roleKetua;
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, 'Beranda'),
          _buildNavItem(1, Icons.calendar_today, 'Jadwal'),
          _buildNavItem(2, Icons.list_alt, 'Laporan'),
          if (isKetua) _buildNavItem(3, Icons.people_outline, 'Warga'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: isSelected ? BoxDecoration(color: AppConstants.primaryColor, borderRadius: BorderRadius.circular(20)) : null,
            child: Icon(icon, color: isSelected ? Colors.white : AppConstants.mutedTextColor),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppConstants.primaryColor : AppConstants.mutedTextColor)),
        ],
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi,';
    if (hour < 17) return 'Selamat Siang,';
    return 'Selamat Malam,';
  }
}
