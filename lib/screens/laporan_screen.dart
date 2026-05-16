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
            const Text(
              'Daftar Laporan Terkini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textColor),
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
          TextField(
            controller: _teksController,
            maxLines: 3,
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton.icon(
              onPressed: _isSending ? null : _kirimLaporan,
              icon: _isSending 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Kirim Laporan', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(LaporanModel laporan) {
    bool isKetua = _currentUser?.role == AppConstants.roleKetua;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  laporan.namaWarga,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.primaryColor),
                ),
                Text(
                  DateFormat('dd MMM, HH:mm').format(laporan.timestamp),
                  style: const TextStyle(fontSize: 10, color: AppConstants.mutedTextColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              laporan.teks,
              style: const TextStyle(fontSize: 14, color: AppConstants.textColor),
            ),
            if (isKetua) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _firestoreService.deleteLaporan(laporan.id),
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: const Text('Hapus', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
