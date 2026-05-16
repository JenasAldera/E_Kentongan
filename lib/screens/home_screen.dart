import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/jadwal_model.dart';
import '../utils/constants.dart';
import 'laporan_screen.dart';
import 'kelola_jadwal_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final List<Widget> _pages = [
      _buildDashboard(),
      const KelolaJadwalScreen(),
      const LaporanScreen(),
    ];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: _currentUser?.nama != null 
              ? const NetworkImage('https://via.placeholder.com/150') // Placeholder image
              : null,
            child: _currentUser?.nama == null ? const Icon(Icons.person) : null,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${_currentUser?.nama ?? 'User'}',
              style: const TextStyle(color: AppConstants.textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Warga RT 05',
              style: TextStyle(color: AppConstants.mutedTextColor, fontSize: 12),
            ),
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
              if (mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          )
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE), // Light Pink/Red
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 20, color: Color(0xFFC62828)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lingkungan Anda dalam keadaan aman',
                    style: TextStyle(color: Color(0xFFC62828), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Map Card
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                const Positioned(
                  top: 20,
                  left: 20,
                  child: Icon(Icons.location_on, color: Color(0xFFFFCDD2), size: 40),
                ),
                Positioned(
                  bottom: -20,
                  right: -20,
                  child: Icon(Icons.shield, color: Colors.white.withOpacity(0.1), size: 150),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Action Cards
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Darurat',
                  Icons.report_problem,
                  Colors.amber,
                  () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  'Jadwal',
                  Icons.calendar_today,
                  Colors.amber,
                  () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text(
            'Aktivitas Terbaru',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor),
          ),
          const SizedBox(height: 12),

          // Activity List
          _buildActivityItem('Pencurian Helm di Gang 4', 'Baru Saja', Icons.local_fire_department, Colors.orange),
          _buildActivityItem('Lampu Jalan Mati', '2 jam yang lalu', Icons.lightbulb, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: AppConstants.mutedTextColor, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppConstants.mutedTextColor),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home, 'Beranda'),
          _buildNavItem(1, Icons.calendar_month, 'Jadwal'),
          _buildNavItem(2, Icons.list_alt, 'Laporan'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppConstants.mutedTextColor),
            if (!isSelected)
              Text(label, style: const TextStyle(fontSize: 10, color: AppConstants.mutedTextColor)),
          ],
        ),
      ),
    );
  }
}
