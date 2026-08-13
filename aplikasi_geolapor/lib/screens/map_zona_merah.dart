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
                          child: const Icon(
                            Icons.warning_rounded,
                            color: Colors.red,
                            size: 30,
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
