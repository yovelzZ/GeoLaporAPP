import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class FormLaporan extends StatefulWidget {
  const FormLaporan({super.key});

  @override
  State<FormLaporan> createState() => _FormLaporanState();
}

class _FormLaporanState extends State<FormLaporan> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  
  File? _image;
  Position? _currentPosition;
  bool _isLoading = false;

  // Fungsi Buka Kamera
  Future<void> _ambilFoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera, 
      imageQuality: 70, // Kompres foto agar tidak berat saat dikirim
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Fungsi Dapatkan Koordinat GPS
  Future<void> _ambilLokasi() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception("GPS HP Anda belum dinyalakan");

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception("Izin lokasi ditolak");
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi Kirim ke API (MEMPERBAIKI ERROR SEBELUMNYA)
  Future<void> _kirimData() async {
    // 1. Cek apakah ada yang masih kosong
    if (_judulController.text.isEmpty || 
        _deskripsiController.text.isEmpty || 
        _image == null || 
        _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi Judul, Deskripsi, Foto, dan Lokasi!'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Panggil API dengan 5 argumen berurutan
    bool isSuccess = await ApiService.kirimLaporan(
      _judulController.text,        // Argumen 1
      _deskripsiController.text,    // Argumen 2
      _currentPosition!.latitude,   // Argumen 3
      _currentPosition!.longitude,  // Argumen 4
      _image!,                      // Argumen 5
    );

    setState(() => _isLoading = false);

    // 3. Cek hasil dari Server
    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeay! Laporan Anda berhasil dikirim.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
      Navigator.pop(context); // Otomatis kembali ke layar Home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim ke server. Coba lagi.'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tulis Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF4A90E2),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BAGIAN FOTO
                const Text("Bukti Foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _ambilFoto,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text("Ketuk untuk ambil foto dari Kamera", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // BAGIAN FORM INPUT TEKS
                const Text("Judul Keluhan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    hintText: "Contoh: Jalan berlubang di Ring Road",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Deskripsi Detail", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _deskripsiController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Jelaskan detail kerusakannya di sini...",
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 24),

                // BAGIAN LOKASI
                const Text("Titik Lokasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          _currentPosition != null 
                              ? "Lat: ${_currentPosition!.latitude}\nLng: ${_currentPosition!.longitude}"
                              : "Lokasi belum didapatkan",
                          style: TextStyle(color: _currentPosition != null ? Colors.black : Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _ambilLokasi,
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                // TOMBOL KIRIM
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _kirimData,
                    child: const Text("KIRIM LAPORAN", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // ANIMASI LOADING SAAT MENGIRIM DATA
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}