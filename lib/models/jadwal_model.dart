class JadwalModel {
  final String id;
  final String namaRegu;
  final String tanggal;
  final String jamMulai;
  final String jamSelesai;
  final List<String> namaWarga;
  final List<String> userIds;
  final String posRonda;

  JadwalModel({
    required this.id,
    required this.namaRegu,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.namaWarga,
    required this.userIds,
    required this.posRonda,
  });

  Map<String, dynamic> toMap() {
    return {
      'namaRegu': namaRegu,
      'tanggal': tanggal,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'namaWarga': namaWarga,
      'userIds': userIds,
      'posRonda': posRonda,
    };
  }

  factory JadwalModel.fromMap(Map<String, dynamic> map, String id) {
    return JadwalModel(
      id: id,
      namaRegu: map['namaRegu'] ?? 'Tanpa Regu',
      tanggal: map['tanggal'] ?? '',
      jamMulai: map['jamMulai'] ?? '',
      jamSelesai: map['jamSelesai'] ?? '',
      namaWarga: List<String>.from(map['namaWarga'] ?? []),
      userIds: List<String>.from(map['userIds'] ?? []),
      posRonda: map['posRonda'] ?? '',
    );
  }
}
