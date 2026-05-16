import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  String _selectedRole = AppConstants.roleWarga;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      var user = await _authService.register(
        _emailController.text,
        _passwordController.text,
        _namaController.text,
        _noHpController.text,
        _alamatController.text,
        _selectedRole,
      );
      setState(() {
        _isLoading = false;
      });
      if (user != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil. Silakan Login.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Gagal.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppConstants.primaryColor),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active, size: 20, color: AppConstants.accentColor),
            ),
            const SizedBox(width: 8),
            const Text(
              'E-Kentongan',
              style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outlined, color: AppConstants.mutedTextColor),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const Text(
              'Daftar Akun Baru',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textColor),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bergabunglah dengan komunitas keamanan lingkungan digital untuk RT yang lebih aman dan teratur.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppConstants.mutedTextColor),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField('Nama Lengkap', 'Contoh: Budi Santoso', _namaController, Icons.person_outlined),
                    const SizedBox(height: 16),
                    _buildInputField('Email', 'budi@email.com', _emailController, Icons.email_outlined),
                    const SizedBox(height: 16),
                    _buildInputField('Nomor HP', '0812xxxx', _noHpController, Icons.phone_outlined),
                    const SizedBox(height: 16),
                    _buildInputField('Alamat', 'Jl. Keamanan No. 12, RT 05', _alamatController, Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    const Text('Pilihan Role', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildRoleCard(AppConstants.roleWarga, 'Warga', Icons.group_outlined)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildRoleCard(AppConstants.roleKetua, 'Ketua RT', Icons.assignment_ind_outlined)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Kata Sandi', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: AppConstants.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value!.length < 6 ? 'Password minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Daftar ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  Icon(Icons.person_add_alt_1_outlined),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Sudah punya akun? ',
                            style: TextStyle(color: AppConstants.mutedTextColor),
                            children: [
                              TextSpan(
                                text: 'Masuk Sekarang',
                                style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user_outlined, size: 16, color: AppConstants.mutedTextColor),
                const SizedBox(width: 4),
                const Text('Data terenkripsi dan aman', style: TextStyle(fontSize: 12, color: AppConstants.mutedTextColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: AppConstants.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
        ),
      ],
    );
  }

  Widget _buildRoleCard(String role, String label, IconData icon) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppConstants.primaryColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppConstants.primaryColor : AppConstants.mutedTextColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppConstants.primaryColor : AppConstants.mutedTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
