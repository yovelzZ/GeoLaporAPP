import 'package:flutter/material.dart';
import 'form_laporan.dart'; 
import 'peta_laporan.dart'; 
import 'progress_keluhan.dart';
import 'scan_qr.dart';
import 'map_zona_merah.dart';
import 'profile_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; 
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.add(const TutorialScreen()); 
    _pages.add(_buildHomeContent()); 
    _pages.add(const ProfileScreen()); 
  }

  @override
  Widget build(BuildContext context) {
    _pages[1] = _buildHomeContent();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), 
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF4A90E2),
            unselectedItemColor: Colors.grey[400],
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), activeIcon: Icon(Icons.menu_book_rounded, size: 28), label: "Panduan"),
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), activeIcon: Icon(Icons.home_rounded, size: 28), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.person_rounded), activeIcon: Icon(Icons.person_rounded, size: 28), label: "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER MODERN ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF7F9FC),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "GeoLapor", 
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5)
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF4A90E2), Color(0xFF007AFF)]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text("DIY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Bersama Membangun Yogyakarta", 
                        style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1E293B)), 
                      onPressed: () {}
                    ),
                  )
                ],
              ),
            ),

            // --- KONTAINER BAWAH ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -5))]
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // BANNER SAMBUTAN (Opsional Tambahan Estetika)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft, end: Alignment.bottomRight
                          ),
                          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Ada fasilitas yang rusak?", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text("Laporkan sekarang agar segera ditangani oleh dinas terkait.", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 40),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // GRID 4 MENU UTAMA
                      const Text("Layanan Warga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), 
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.05, 
                        children: [
                          _buildMenuCard(context, "Lapor\nKeluhan", Icons.add_photo_alternate_rounded, const Color(0xFF4A90E2), const FormLaporan()),
                          _buildMenuCard(context, "Progress\nLaporan", Icons.format_list_bulleted_rounded, const Color(0xFF10B981), const ProgressKeluhan()), 
                          _buildMenuCard(context, "Peta\nFasilitas", Icons.map_rounded, const Color(0xFFF59E0B), const PetaLaporan()),
                          _buildMenuCard(context, "Zona\nMerah", Icons.warning_rounded, const Color(0xFFEF4444), const MapZonaMerah(), isAlert: true),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // BAGIAN BERITA (TIDAK DIUBAH KONTENNYA, HANYA DIPERCANTIK SEDIKIT)
                      const Text("Berita Yogyakarta", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180, // Ditinggikan sedikit agar tidak overflow
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
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
      );
  }

  // WIDGET KOTAK MENU DENGAN DESAIN MODERN
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color colorTheme, Widget? targetScreen, {bool isAlert = false}) {
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
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(color: colorTheme.withOpacity(0.05), spreadRadius: 0, blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorTheme.withOpacity(0.1), 
                shape: BoxShape.circle
              ),
              child: Icon(icon, size: 36, color: colorTheme),
            ),
            const SizedBox(height: 16),
            Text(
              title, 
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isAlert ? Colors.redAccent : const Color(0xFF1E293B), height: 1.2)
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET KARTU BERITA
  Widget _buildNewsCard(String title, String imageUrl) {
    return Container(
      width: 240, // Sedikit diperlebar
      margin: const EdgeInsets.only(right: 16, bottom: 8), // Bottom margin for shadow
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Image.network(imageUrl, height: 100, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              title, 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis, 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), height: 1.3)
            ),
          )
        ],
      ),
    );
  }
}