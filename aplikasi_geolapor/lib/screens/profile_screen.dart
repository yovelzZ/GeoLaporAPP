import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'pengaturan_akun_screen.dart';
import 'riwayat_laporan_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userName;
  String? _userEmail;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString('user_email');
      _isLoggedIn = prefs.getString('auth_token') != null;
    });
  }

  void _logout() async {
    await ApiService.logout();
    _loadProfile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda telah logout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header Profile
          Container(
            padding: const EdgeInsets.all(24.0),
            color: const Color(0xFF4A90E2),
            width: double.infinity,
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Color(0xFF4A90E2)),
                ),
                const SizedBox(height: 16),
                Text(
                  _isLoggedIn ? (_userName ?? 'Pengguna') : 'Guest (Belum Login)',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoggedIn ? (_userEmail ?? '') : 'Login untuk mengakses riwayat',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Menu List
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!_isLoggedIn)
                    _buildProfileMenu(Icons.login, "Login / Daftar", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())).then((_) => _loadProfile());
                    }),
                  
                  if (_isLoggedIn) ...[
                    _buildProfileMenu(Icons.history, "Riwayat Laporan Saya", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatLaporanScreen()));
                    }),
                    _buildProfileMenu(Icons.settings, "Pengaturan Akun", onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PengaturanAkunScreen())).then((_) => _loadProfile());
                    }),
                  ],
                  
                  _buildProfileMenu(Icons.help_outline, "Pusat Bantuan", onTap: () {}),
                  _buildProfileMenu(Icons.info_outline, "Tentang Aplikasi", onTap: () {}),
                  
                  if (_isLoggedIn) ...[
                    const SizedBox(height: 24),
                    _buildProfileMenu(Icons.logout, "Keluar", isLogout: true, onTap: _logout),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.withOpacity(0.1) : const Color(0xFF4A90E2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF4A90E2)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
