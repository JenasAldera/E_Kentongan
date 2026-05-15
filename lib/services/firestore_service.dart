import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/jadwal_model.dart';
import '../models/laporan_model.dart';
import '../models/checkin_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // JADWAL
  Stream<List<JadwalModel>> getJadwal() {
    return _db.collection('jadwal').orderBy('tanggal').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => JadwalModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addJadwal(JadwalModel jadwal) {
    return _db.collection('jadwal').add(jadwal.toMap());
  }

  Future<void> updateJadwal(JadwalModel jadwal) {
    return _db.collection('jadwal').doc(jadwal.id).update(jadwal.toMap());
  }

  Future<void> deleteJadwal(String id) {
    return _db.collection('jadwal').doc(id).delete();
  }

  // CHECK-IN
  Future<void> checkIn(CheckInModel checkIn) {
    return _db.collection('checkin').add(checkIn.toMap());
  }

  // LAPORAN
  Stream<List<LaporanModel>> getLaporan() {
    return _db.collection('laporan').orderBy('timestamp', descending: true).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => LaporanModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addLaporan(LaporanModel laporan) {
    return _db.collection('laporan').add(laporan.toMap());
  }
}
