import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // GANTI LINK NGROK DI BAWAH INI DENGAN YANG TERBARU
  // Pastikan ujungnya menggunakan /api
  static const String baseUrl = 'https://nontraveling-scottie-improvably.ngrok-free.dev/api';

  // ==============================================================
  // 0. FUNGSI AUTHENTIKASI & TOKEN
  // ==============================================================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Accept': 'application/json'},
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);
        return data;
      }
      return {'error': true, 'message': 'Login gagal. Periksa kembali email & password.'};
    } catch (e) {
      return {'error': true, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }

  static Future<Map<String, dynamic>?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Accept': 'application/json'},
        body: {'name': name, 'email': email, 'password': password},
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);
        return data;
      } else if (response.statusCode == 422) {
        final data = json.decode(response.body);
        String errorMessage = data['message'] ?? 'Data tidak valid.';
        if (data['errors'] != null) {
            if (data['errors']['email'] != null) errorMessage = data['errors']['email'][0];
            else if (data['errors']['password'] != null) errorMessage = data['errors']['password'][0];
            else if (data['errors']['name'] != null) errorMessage = data['errors']['name'][0];
        }
        return {'error': true, 'message': errorMessage};
      }
      return {'error': true, 'message': 'Gagal mendaftar. Silakan coba lagi.'};
    } catch (e) {
      return {'error': true, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }

  static Future<void> logout() async {
    try {
      String? token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  static Future<bool> updateProfile(String? name, String? password) async {
    try {
      String? token = await getToken();
      if (token == null) return false;
      
      Map<String, String> body = {};
      if (name != null && name.isNotEmpty) body['name'] = name;
      if (password != null && password.isNotEmpty) body['password'] = password;

      final response = await http.post(
        Uri.parse('$baseUrl/user/update'),
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );
      if (response.statusCode == 200) {
        if (name != null && name.isNotEmpty) {
           final prefs = await SharedPreferences.getInstance();
           await prefs.setString('user_name', name);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> ambilRiwayatLaporan() async {
    try {
      String? token = await getToken();
      if (token == null) return [];
      final response = await http.get(
        Uri.parse('$baseUrl/laporan/me'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> toggleDukungan(int laporanId) async {
    try {
      String? token = await getToken();
      if (token == null) return null; // Harus login

      final response = await http.post(
        Uri.parse('$baseUrl/laporan/$laporanId/dukung'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> ambilKomentar(int laporanId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/laporan/$laporanId/komentar'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> kirimKomentar(int laporanId, String isi) async {
    try {
      String? token = await getToken();
      if (token == null) return null; // Harus login

      final response = await http.post(
        Uri.parse('$baseUrl/laporan/$laporanId/komentar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {'isi_komentar': isi},
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==============================================================
  // 1. FUNGSI KIRIM LAPORAN (DENGAN FOTO)
  // ==============================================================
  static Future<bool> kirimLaporan(
      String judul, String deskripsi, String kategori, double lat, double lng, File fotoFile) async {
    try {
      var uri = Uri.parse('$baseUrl/laporan');
      var request = http.MultipartRequest('POST', uri);

      // Tambahkan Bearer Token jika user login
      String? token = await getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // A. Memasukkan data teks
      request.fields['judul'] = judul;
      request.fields['deskripsi'] = deskripsi;
      request.fields['kategori'] = kategori;
      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = lng.toString();

      // B. Memasukkan file gambar (Kunci 'foto' harus sama dengan di Laravel)
      var multipartFile = await http.MultipartFile.fromPath(
        'foto', // Kunci ini SANGAT PENTING
        fotoFile.path,
      );
      request.files.add(multipartFile);

      // C. Kirim ke Server dengan batas waktu 15 detik
      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      
      // Ambil jawaban dari server untuk melihat log error jika gagal
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Laporan beserta foto berhasil terkirim!");
        return true;
      } else {
        print("❌ Gagal mengirim. Kode Status: ${response.statusCode}");
        print("❌ Alasan dari Server: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ TERJADI ERROR: $e");
      return false;
    }
  }

  // ==============================================================
  // 2. FUNGSI AMBIL SEMUA LAPORAN
  // ==============================================================
  static Future<List<dynamic>> ambilSemuaLaporan() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/laporan'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("❌ Gagal mengambil data: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ TERJADI ERROR PADA KONEKSI: $e");
      return [];
    }
  }
}