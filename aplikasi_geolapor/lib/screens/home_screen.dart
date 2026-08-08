import 'package:flutter/material.dart';
import 'form_laporan.dart'; 
import 'peta_laporan.dart'; 
import 'progress_keluhan.dart';
import 'scan_qr.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A90E2), 
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER (BIRU) ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Laporkeun Keluhanmu!", 
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Ajukan keluhan anda terkait fasilitas publik", 
                        style: TextStyle(fontSize: 13, color: Colors.white70)
                      ),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_active, color: Color(0xFF4A90E2)), 
                      onPressed: () {}
                    ),
                  )
                ],
              ),
            ),

            // --- KONTAINER PUTIH MELENGKUNG ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GRID 4 MENU UTAMA
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), 
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.1, 
                        children: [
                          _buildMenuCard(context, "Lapor Keluhan", Icons.edit_document, const FormLaporan()),
                          _buildMenuCard(context, "Scan QR", Icons.qr_code_scanner, const ScanQR()), 
                          _buildMenuCard(context, "Progress Keluhan", Icons.pending_actions, const ProgressKeluhan()), 
                          _buildMenuCard(context, "Mapping Fasilitas", Icons.map_outlined, const PetaLaporan()),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // BAGIAN BERITA (SCROLL HORIZONTAL)
                      const Text("Berita Yogyakarta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Berita diubah menjadi lokalan Yogyakarta
                            _buildNewsCard("Perbaikan Jalan Berlubang di Ring Road Utara Sleman Rampung", "https://asset.kompas.com/crops/aS1KScWRLzD-IsS0ekcuCMUraMo=/63x0:1076x675/1200x800/data/photo/2025/07/14/6875086bb7685.jpg"),
                            _buildNewsCard("Fasilitas Pelican Crossing Baru Terpasang di Kawasan Malioboro", "https://travelspromo.com/wp-content/uploads/2019/03/Kereta-hias-di-Alkid-Yogyakarta-wajahalun2kiduljogja.jpg"),
                            _buildNewsCard("Penambahan Tempat Sampah Pemilah di Alun-Alun Kidul Yogyakarta", "https://travelspromo.com/wp-content/uploads/2019/03/Angkringan-dan-lesehan-disekitar-Alkid-Yogyakarta-wajahalun2kiduljogja.jpg"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      
      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey[400],
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "Tutorial"),
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
    );
  }

  // WIDGET BANTUAN: KOTAK MENU
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget? targetScreen) {
    return InkWell(
      onTap: () {
        if (targetScreen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Fitur $title segera hadir!"), 
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 2, blurRadius: 15, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF4A90E2).withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: const Color(0xFF4A90E2)),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  // WIDGET BANTUAN: KARTU BERITA
  Widget _buildNewsCard(String title, String imageUrl) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Image.network(imageUrl, height: 90, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}