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
    // Menarik data dari server saat layar peta pertama kali dibuka
    tarikDataDariServer();
  }

  Future<void> tarikDataDariServer() async {
    var dataMasuk = await ApiService.ambilSemuaLaporan();
    setState(() {
      listLaporan = dataMasuk;
      isLoading = false; // Matikan animasi loading setelah data didapat
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peta Laporan Warga"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      // Jika masih loading, tampilkan animasi muter. Jika selesai, tampilkan Peta.
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                // Pusatkan kamera peta di laporan pertama. 
                // Jika database kosong, arahkan default ke Kecamatan Mlati, Sleman (-7.7329, 110.3622)
                initialCenter: listLaporan.isNotEmpty
                    ? LatLng(
                        double.parse(listLaporan[0]['latitude'].toString()),
                        double.parse(listLaporan[0]['longitude'].toString()))
                    : const LatLng(-7.7329, 110.3622),
                initialZoom: 13.0,
              ),
              children: [
                // Ini untuk memuat gambar peta gratis dari OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.aplikasi.geolapor',
                ),
                // Ini untuk menyebar titik-titik pin merah (Marker) laporan di atas peta
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
                        // Jika pin merah diklik, munculkan judul laporannya
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Masalah: ${laporan['judul']}\nStatus: ${laporan['status']}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.blue[800],
                              duration: const Duration(seconds: 3),
                            ),
                          );
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