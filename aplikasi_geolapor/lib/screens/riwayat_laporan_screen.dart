import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  List<dynamic> _laporans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyLaporans();
  }

  Future<void> _fetchMyLaporans() async {
    final data = await ApiService.ambilRiwayatLaporan();
    setState(() {
      _laporans = data;
      _isLoading = false;
    });
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

  // --- FUNGSI MENAMPILKAN BOTTOM SHEET DETAIL ---
  void _tampilkanDetailLaporan(BuildContext context, dynamic laporan) {
    String foto = laporan['foto'] ?? '';
    String fotoUrl = '';
    
    if (foto.isNotEmpty) {
      fotoUrl = ApiService.baseUrl.replaceAll('/api', '/storage/') + foto;
    }

    String judul = laporan['judul'] ?? 'Tanpa Judul';
    String deskripsi = laporan['deskripsi'] ?? 'Tidak ada deskripsi';
    String status = laporan['status'] ?? 'Menunggu';
    String kategori = laporan['kategori'] ?? 'Lainnya';
    
    String tanggalRaw = laporan['created_at'] ?? '';
    String tanggal = "Baru saja";
    if (tanggalRaw.length > 10) {
      tanggal = tanggalRaw.substring(0, 10);
    }

    Color statusColor = Colors.orange;
    if (status.toLowerCase() == 'selesai') statusColor = Colors.green;
    if (status.toLowerCase() == 'diproses') statusColor = Colors.blue;

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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis handle atas
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
              
              // --- GAMBAR BISA DIKLIK ---
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
              
              // --- KONTEN TEXT ---
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
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        tanggal,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.category_rounded, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 6),
                  Text(
                    kategori,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Riwayat Laporan Saya", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4A90E2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laporans.isEmpty
              ? const Center(child: Text("Anda belum pernah membuat laporan."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _laporans.length,
                  itemBuilder: (context, index) {
                    final item = _laporans[index];
                    Color statusColor = Colors.orange;
                    if (item['status'] == 'Selesai') statusColor = Colors.green;
                    if (item['status'] == 'Diproses') statusColor = Colors.blue;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        onTap: () => _tampilkanDetailLaporan(context, item), // Fungsi klik ditambahkan di sini
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(item['judul'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(item['deskripsi'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item['status'] ?? 'Menunggu',
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]), // Indikator klik
                      ),
                    );
                  },
                ),
    );
  }
}