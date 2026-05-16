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
  bool _isSending = false;

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
      setState(() => _isSending = true);
      LaporanModel laporan = LaporanModel(
        id: '',
        userId: _currentUser!.uid,
        namaWarga: _currentUser!.nama,
        teks: _teksController.text,
        timestamp: DateTime.now(),
      );
      await _firestoreService.addLaporan(laporan);
      _teksController.clear();
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan Terkirim')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNewReportCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Laporan Terkini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.tune, size: 20, color: AppConstants.mutedTextColor)),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<LaporanModel>>(
              stream: _firestoreService.getLaporan(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var laporanList = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    var lapor = laporanList[index];
                    return _buildReportItem(lapor);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Icon(Icons.history, color: AppConstants.mutedTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewReportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buat Laporan Baru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text(
            'Laporkan kejadian atau aktivitas mencurigakan di lingkungan Anda.',
            style: TextStyle(fontSize: 13, color: AppConstants.mutedTextColor),
          ),
          const SizedBox(height: 16),
          const Text('Detail Kejadian', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _teksController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Ceritakan apa yang terjadi...',
              hintStyle: const TextStyle(fontSize: 14, color: AppConstants.mutedTextColor),
              filled: true,
              fillColor: AppConstants.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('0 / 500 karakter', style: TextStyle(fontSize: 10, color: AppConstants.mutedTextColor)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _kirimLaporan,
              icon: _isSending 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Kirim Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(LaporanModel laporan) {
    // Determining status badge based on some logic (placeholder logic)
    String status = 'Aktif';
    Color statusColor = Colors.amber;
    if (laporan.teks.contains('Pencurian')) {
      status = 'Perlu Tindakan';
      statusColor = Colors.red;
    } else if (laporan.teks.contains('Selesai')) {
      status = 'Selesai';
      statusColor = Colors.green;
    }

    String timeAgo = _getTimeAgo(laporan.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.report_problem_outlined, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ],
                      ),
                    ),
                    Text(timeAgo, style: const TextStyle(fontSize: 10, color: AppConstants.mutedTextColor)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  laporan.teks.split('\n').first, // Simple title from first line
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  laporan.teks,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppConstants.mutedTextColor),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppConstants.mutedTextColor),
                    const SizedBox(width: 4),
                    Text(
                      laporan.namaWarga,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppConstants.mutedTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) return 'Baru Saja';
    if (difference.inHours < 24) return '${difference.inHours} jam yang lalu';
    return DateFormat('dd MMM').format(dateTime);
  }
}
