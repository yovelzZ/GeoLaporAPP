import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class MapZonaMerah extends StatefulWidget {
  const MapZonaMerah({super.key});

  @override
  State<MapZonaMerah> createState() => _MapZonaMerahState();
}

class _MapZonaMerahState extends State<MapZonaMerah> {
  LatLng? _currentPosition;
  List<dynamic> _activeLaporans = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // 1. Dapatkan lokasi saat ini
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          _currentPosition = LatLng(position.latitude, position.longitude);
        }
      }
    } catch (e) {
      debugPrint("Gagal mendapatkan lokasi: $e");
    }

    // Default jika gagal
    _currentPosition ??= const LatLng(5.1802, 97.1507); // Default Lhokseumawe/Aceh

    // 2. Ambil data dari server
    final semuaLaporan = await ApiService.ambilSemuaLaporan();
    
    setState(() {
      // Filter hanya yang bukan 'Selesai'
      _activeLaporans = semuaLaporan.where((item) {
        final status = item['status'].toString().toLowerCase();
        return status != 'selesai';
      }).toList();
      _isLoading = false;
    });
  }

  void _recenterMap() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    }
  }

  // --- FUNGSI LIHAT FOTO FULL SCREEN ---
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
        title: const Text("Peta Zona Merah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.aplikasi_geolapor',
                    ),
                    // Layer Lingkaran Merah untuk Heatmap
                    CircleLayer(
                      circles: _activeLaporans.map((laporan) {
                        return CircleMarker(
                          point: LatLng(
                            double.parse(laporan['latitude'].toString()), 
                            double.parse(laporan['longitude'].toString())
                          ),
                          color: Colors.red.withOpacity(0.3),
                          borderStrokeWidth: 0,
                          useRadiusInMeter: true,
                          radius: 150, // Radius 150 meter
                        );
                      }).toList(),
                    ),
                    // Layer Marker Inti
                    MarkerLayer(
                      markers: _activeLaporans.map((laporan) {
                        return Marker(
                          point: LatLng(
                            double.parse(laporan['latitude'].toString()), 
                            double.parse(laporan['longitude'].toString())
                          ),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            // --- EVENT ONTAP DITAMBAHKAN DI SINI ---
                            onTap: () {
                              _tampilkanDetailLaporan(context, laporan);
                            },
                            child: const Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  ],
                ),
                
                // Info Box Top
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Terdapat ${_activeLaporans.length} titik infrastruktur rusak/rawan yang belum selesai diperbaiki.",
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Button Recenter GPS
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.redAccent),
                    onPressed: _recenterMap,
                  ),
                )
              ],
            ),
    );
  }
}