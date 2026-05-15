class JadwalModel {
  final String id;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String namaWarga;
  final String userId;
  final String posRonda;

  JadwalModel({
    required this.id,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaWarga,
    required this.userId,
    required this.posRonda,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'namaWarga': namaWarga,
      'userId': userId,
      'posRonda': posRonda,
    };
  }

  factory JadwalModel.fromMap(Map<String, dynamic> map, String id) {
    return JadwalModel(
      id: id,
      tanggal: map['tanggal'] ?? '',
      jamMulai: map['jamMulai'] ?? '',
      jamSelesai: map['jamSelesai'] ?? '',
      namaWarga: map['namaWarga'] ?? '',
      userId: map['userId'] ?? '',
      posRonda: map['posRonda'] ?? '',
    );
  }
}
