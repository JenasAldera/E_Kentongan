class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String role;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'noHp': noHp,
      'alamat': alamat,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      noHp: map['noHp'] ?? '',
      alamat: map['alamat'] ?? '',
      role: map['role'] ?? 'warga',
    );
  }
}
