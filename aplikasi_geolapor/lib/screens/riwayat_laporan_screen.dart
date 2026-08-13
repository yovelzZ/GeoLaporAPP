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
                      ),
                    );
                  },
                ),
    );
  }
}
