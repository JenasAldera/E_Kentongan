import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanModel {
  final String id;
  final String userId;
  final String namaWarga;
  final String teks;
  final DateTime timestamp;

  LaporanModel({
    required this.id,
    required this.userId,
    required this.namaWarga,
    required this.teks,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'namaWarga': namaWarga,
      'teks': teks,
      'timestamp': timestamp,
    };
  }

  factory LaporanModel.fromMap(Map<String, dynamic> map, String id) {
    return LaporanModel(
      id: id,
      userId: map['userId'] ?? '',
      namaWarga: map['namaWarga'] ?? '',
      teks: map['teks'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
