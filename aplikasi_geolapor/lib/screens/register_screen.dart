import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua bidang!')));
      return;
    }

    setState(() => _isLoading = true);
    final result = await ApiService.register(_nameController.text, _emailController.text, _passwordController.text);
    setState(() => _isLoading = false);

    if (result != null && result['error'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil Mendaftar!')));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      String errMsg = result != null ? result['message'] : 'Gagal Mendaftar.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun'), backgroundColor: const Color(0xFF4A90E2)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person_add_alt_1, size: 80, color: Color(0xFF4A90E2)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password (min. 6 karakter)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A90E2), padding: const EdgeInsets.all(16)),
              onPressed: _isLoading ? null : _register,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('DAFTAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
