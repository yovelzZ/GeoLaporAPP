import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // GANTI LINK NGROK DI BAWAH INI DENGAN YANG TERBARU
  // Pastikan ujungnya menggunakan /api
  static const String baseUrl = 'https://nontraveling-scottie-improvably.ngrok-free.dev/api';

  // ==============================================================
  // 1. FUNGSI KIRIM LAPORAN (DENGAN FOTO)
  // ==============================================================
  static Future<bool> kirimLaporan(
      String judul, String deskripsi, double lat, double lng, File fotoFile) async {
    try {
      var uri = Uri.parse('$baseUrl/laporan');
      var request = http.MultipartRequest('POST', uri);

      // A. Memasukkan data teks
      request.fields['judul'] = judul;
      request.fields['deskripsi'] = deskripsi;
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