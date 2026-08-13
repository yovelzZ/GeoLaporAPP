import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';

class FormLaporan extends StatefulWidget {
  const FormLaporan({super.key});

  @override
  State<FormLaporan> createState() => _FormLaporanState();
}

class _FormLaporanState extends State<FormLaporan> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();
  
  final List<String> _kategoriOptions = [
    'Jalan', 'Lampu Jalan', 'Drainase', 'Jembatan', 'Fasilitas Umum', 'Lainnya'
  ];
  
  File? _image;
  Position? _currentPosition;
  bool _isLoading = false;

  Future<void> _ambilFoto() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera, 
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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
      
      // Ambil nama alamat dari koordinat (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String fullAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}".toLowerCase();

        // Cek apakah alamat mengandung kata "mlati"
        if (!fullAddress.contains('mlati')) {
          throw Exception("Maaf, pelaporan hanya berlaku di wilayah Kecamatan Mlati, Sleman.");
        }
      }

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceAll("Exception: ", "")),
        backgroundColor: Colors.redAccent,
      ));
      setState(() {
        _currentPosition = null; // Reset jika ditolak
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _kirimData() async {
    if (_judulController.text.isEmpty || 
        _deskripsiController.text.isEmpty || 
        _kategoriController.text.isEmpty ||
        _image == null || 
        _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi Kategori, Judul, Deskripsi, Foto, dan Lokasi!'),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    bool isSuccess = await ApiService.kirimLaporan(
      _judulController.text,        
      _deskripsiController.text,    
      _kategoriController.text,     
      _currentPosition!.latitude,   
      _currentPosition!.longitude,  
      _image!,                      
    );

    setState(() => _isLoading = false);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeay! Laporan Anda berhasil dikirim.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim ke server. Coba lagi.'),
          backgroundColor: Colors.redAccent,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Tulis Laporan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FOTO AREA (Lebih menonjol)
                GestureDetector(
                  onTap: _ambilFoto,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                      border: _image == null ? Border.all(color: Colors.blue.withOpacity(0.3), width: 2, style: BorderStyle.solid) : null,
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 40, color: Colors.blue),
                              ),
                              const SizedBox(height: 12),
                              const Text("Ambil Bukti Foto", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                              const SizedBox(height: 4),
                              const Text("Pastikan foto jelas & terang", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // LOKASI AREA (Modern Card)
                const Text("Lokasi Kejadian", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _ambilLokasi,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: _currentPosition != null ? Colors.green.withOpacity(0.3) : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _currentPosition != null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _currentPosition != null ? Icons.check_circle_rounded : Icons.location_on_rounded, 
                            color: _currentPosition != null ? Colors.green : Colors.orange
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentPosition != null ? "Lokasi Ditemukan" : "Deteksi Lokasi GPS",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              if (_currentPosition != null)
                                Text(
                                  "${_currentPosition!.latitude}, ${_currentPosition!.longitude}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                )
                              else
                                const Text("Ketuk untuk mendapatkan koordinat", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (_currentPosition == null)
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // FORM TEXT AREA
                const Text("Detail Laporan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 12),
                
                // Kategori
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                    return _kategoriOptions.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (String selection) => _kategoriController.text = selection,
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    controller.addListener(() => _kategoriController.text = controller.text);
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      decoration: InputDecoration(
                        labelText: "Kategori Infrastruktur",
                        hintText: "Misal: Jalan",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.category_rounded, color: Colors.blue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Judul
                TextFormField(
                  controller: _judulController,
                  decoration: InputDecoration(
                    labelText: "Judul Singkat",
                    hintText: "Contoh: Jalan berlubang di Ring Road",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.title_rounded, color: Colors.blue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),

                // Deskripsi
                TextFormField(
                  controller: _deskripsiController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Deskripsi Lengkap",
                    hintText: "Jelaskan kronologi atau kondisi secara detail...",
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 60.0),
                      child: Icon(Icons.description_rounded, color: Colors.blue),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.2))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                  ),
                ),
                
                const SizedBox(height: 40),

                // TOMBOL KIRIM (Modern Full Width)
                Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF007AFF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _isLoading ? null : _kirimData,
                    child: const Text("KIRIM LAPORAN", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}