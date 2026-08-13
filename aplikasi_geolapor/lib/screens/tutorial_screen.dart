import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER (BIRU)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pusat Bantuan",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,color: Color(0xFF1E88E5)),
                ),
                SizedBox(height: 6),
                Text(
                  "Panduan menggunakan aplikasi GeoLapor",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,color: Color(0xFF1E88E5)),
                ),
              ],
            ),
          ),

          // BODY PUTIH MELENGKUNG
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
                    // CAROUSEL LANGKAH MELAPOR
                    const Text("Cara Lapor Keluhan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildStepCard(
                            "1", "Izinkan GPS", "Buka menu lapor, lalu aktifkan dan izinkan akses lokasi (GPS) pada HP Anda.",
                            Colors.blue, Icons.location_on_rounded
                          ),
                          _buildStepCard(
                            "2", "Foto Bukti", "Ambil foto kondisi jalan atau fasilitas yang rusak dengan jelas dan terang.",
                            Colors.orange, Icons.camera_alt_rounded
                          ),
                          _buildStepCard(
                            "3", "Isi Form", "Pilih kategori dan ceritakan detail kerusakan tersebut agar mudah dipahami admin.",
                            Colors.green, Icons.edit_document
                          ),
                          _buildStepCard(
                            "4", "Kirim", "Tekan tombol kirim dan pantau terus perkembangannya di halaman Progress.",
                            Colors.purple, Icons.send_rounded
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // STATUS ALUR PENANGANAN
                    const Text("Arti Status Laporan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildStatusInfo(Icons.pending_actions, "Menunggu", "Laporan Anda telah masuk ke sistem dan sedang menunggu antrean verifikasi admin.", Colors.orange),
                    _buildStatusInfo(Icons.autorenew, "Diproses", "Laporan telah diverifikasi dan tim terkait sedang terjun ke lapangan untuk perbaikan.", Colors.blue),
                    _buildStatusInfo(Icons.check_circle, "Selesai", "Fasilitas atau infrastruktur telah selesai diperbaiki dan bisa digunakan normal.", Colors.green),
                    
                    const SizedBox(height: 32),

                    // FAQ (ACCORDION)
                    const Text("Tanya Jawab (FAQ)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildFaqItem("Apakah laporan saya bisa dilihat orang lain?", "Ya, aplikasi ini bersifat publik (sosial). Warga lain bisa melihat laporan Anda dan ikut memberikan dukungan/upvote."),
                    _buildFaqItem("Berapa lama laporan ditangani?", "Bergantung pada tingkat urgensi dan ketersediaan anggaran dinas terkait. Laporan dengan 'Dukungan' terbanyak biasanya lebih diprioritaskan."),
                    _buildFaqItem("Apakah saya harus mendaftar akun?", "Anda bisa membaca dan melihat daftar keluhan tanpa mendaftar (Guest). Namun, Anda diwajibkan membuat akun untuk membuat laporan baru atau memberikan komentar."),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // WIDGET CARD UNTUK CAROUSEL LANGKAH
  Widget _buildStepCard(String stepNum, String title, String desc, Color color, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: Text(stepNum, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54), maxLines: 4, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // WIDGET ARTI STATUS
  Widget _buildStatusInfo(IconData icon, String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // WIDGET TANYA JAWAB (FAQ)
  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent), // Hilangkan garis bawaan ExpansionTile
        child: ExpansionTile(
          iconColor: const Color(0xFF4A90E2),
          collapsedIconColor: Colors.grey,
          title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(answer, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5)),
            )
          ],
        ),
      ),
    );
  }
}
