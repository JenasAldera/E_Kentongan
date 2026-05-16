import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  void _fetchUsers() async {
    var users = await _firestoreService.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Warga'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.nama} dari sistem?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestoreService.deleteUser(user.uid);
              Navigator.pop(context);
              _fetchUsers();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil dihapus')));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _changeRole(UserModel user) {
    String newRole = user.role == AppConstants.roleWarga ? AppConstants.roleKetua : AppConstants.roleWarga;
    String roleName = newRole == AppConstants.roleKetua ? 'Ketua RT' : 'Warga';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Role'),
        content: Text('Ubah role ${user.nama} menjadi $roleName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.updateUserRole(user.uid, newRole);
              Navigator.pop(context);
              _fetchUsers();
            },
            child: const Text('Ya, Ubah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Warga', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: user.role == AppConstants.roleKetua ? AppConstants.primaryColor : AppConstants.accentColor,
                      child: Text(
                        user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?', 
                        style: TextStyle(color: user.role == AppConstants.roleKetua ? Colors.white : AppConstants.primaryColor, fontWeight: FontWeight.bold)
                      ),
                    ),
                    title: Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Role: ${user.role == AppConstants.roleKetua ? 'Ketua RT' : 'Warga'}'),
                        Text('HP: ${user.noHp}'),
                        Text('Alamat: ${user.alamat}', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') _confirmDelete(user);
                        if (value == 'role') _changeRole(user);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'role', child: Text('Ubah Role')),
                        const PopupMenuItem(value: 'delete', child: Text('Hapus Warga')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
