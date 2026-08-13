import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class PetaLaporan extends StatefulWidget {
  const PetaLaporan({super.key});

  @override
  State<PetaLaporan> createState() => _PetaLaporanState();
}

class _PetaLaporanState extends State<PetaLaporan> {
  List<dynamic> listLaporan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tarikDataDariServer();
  }

  Future<void> tarikDataDariServer() async {
    var dataMasuk = await ApiService.ambilSemuaLaporan();
    setState(() {
      listLaporan = dataMasuk;
      isLoading = false; 
    });
  }

  // --- FUNGSI BARU: LIHAT FOTO FULL SCREEN ---
  void _lihatFotoFullScreen(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero, // Memenuhi layar
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Gambar bisa di-zoom (dicubit)
              InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    imageUrl, 
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Gagal memuat gambar", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
              // Tombol Close (X) di pojok kanan atas
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- FUNGSI MENAMPILKAN BOTTOM SHEET ---
  void _tampilkanDetailLaporan(BuildContext context, dynamic laporan) {
    String foto = laporan['foto'] ?? '';
    String fotoUrl = '';
    
    // Format URL gambar menggunakan Base URL API
    if (foto.isNotEmpty) {
      fotoUrl = ApiService.baseUrl.replaceAll('/api', '/storage/') + foto;
    }

    String judul = laporan['judul'] ?? 'Tanpa Judul';
    String deskripsi = laporan['deskripsi'] ?? 'Tidak ada deskripsi';
    String status = laporan['status'] ?? 'Menunggu';
    String kategori = laporan['kategori'] ?? 'Lainnya';

    // Menentukan warna badge status
    Color statusColor;
    if (status.toLowerCase() == 'selesai') {
      statusColor = const Color(0xFF10B981); // Emerald
    } else if (status.toLowerCase() == 'diproses') {
      statusColor = const Color(0xFF3B82F6); // Biru
    } else {
      statusColor = const Color(0xFFF59E0B); // Amber
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tinggi menyesuaikan isi
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis tarik (Drag handle)
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              // --- GAMBAR FOTO (Bisa di-klik) ---
              if (fotoUrl.isNotEmpty)
                GestureDetector(
                  onTap: () => _lihatFotoFullScreen(context, fotoUrl),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          fotoUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Gambar rusak/hilang", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Overlay icon agar user tahu gambar bisa di-klik
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.zoom_out_map_rounded, color: Colors.white, size: 30),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text("Tidak ada foto", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                
              const SizedBox(height: 20),
              
              // --- KONTEN TEKS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.category_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        kategori,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Text(
                judul,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              
              Text(
                deskripsi,
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peta Laporan Warga"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: listLaporan.isNotEmpty
                    ? LatLng(
                        double.parse(listLaporan[0]['latitude'].toString()),
                        double.parse(listLaporan[0]['longitude'].toString()))
                    : const LatLng(-7.7329, 110.3622),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aplikasi.geolapor',
                ),
                MarkerLayer(
                  markers: listLaporan.map((laporan) {
                    return Marker(
                      point: LatLng(
                        double.parse(laporan['latitude'].toString()),
                        double.parse(laporan['longitude'].toString()),
                      ),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () {
                          _tampilkanDetailLaporan(context, laporan);
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
    );
  }
}