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
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  void _confirmDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Warga', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus ${user.nama} dari sistem?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              await _firestoreService.deleteUser(user.uid);
              Navigator.pop(context);
              _fetchUsers();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User berhasil dihapus')));
              }
            },
            child: const Text('Hapus'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Ubah Role', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Ubah role ${user.nama} menjadi $roleName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manajemen Warga',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textColor),
                  ),
                  const Text(
                    'Kelola akun dan peran warga dalam sistem E-Kentongan.',
                    style: TextStyle(fontSize: 14, color: AppConstants.mutedTextColor),
                  ),
                  const SizedBox(height: 24),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: user.role == AppConstants.roleKetua ? AppConstants.primaryColor : AppConstants.accentColor,
                            child: Text(
                              user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?', 
                              style: TextStyle(
                                color: user.role == AppConstants.roleKetua ? Colors.white : AppConstants.primaryColor, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ),
                          title: Text(user.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Role: ${user.role == AppConstants.roleKetua ? 'Ketua RT' : 'Warga'}', style: const TextStyle(fontSize: 12)),
                              Text('HP: ${user.noHp}', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: AppConstants.mutedTextColor),
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
                ],
              ),
            ),
    );
  }
}
