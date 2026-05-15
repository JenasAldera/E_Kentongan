import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;
  final String jadwalId;
  final String userId;
  final String namaWarga;
  final DateTime waktu;

  CheckInModel({
    required this.id,
    required this.jadwalId,
    required this.userId,
    required this.namaWarga,
    required this.waktu,
  });

  Map<String, dynamic> toMap() {
    return {
      'jadwalId': jadwalId,
      'userId': userId,
      'namaWarga': namaWarga,
      'waktu': waktu,
    };
  }

  factory CheckInModel.fromMap(Map<String, dynamic> map, String id) {
    return CheckInModel(
      id: id,
      jadwalId: map['jadwalId'] ?? '',
      userId: map['userId'] ?? '',
      namaWarga: map['namaWarga'] ?? '',
      waktu: (map['waktu'] as Timestamp).toDate(),
    );
  }
}
