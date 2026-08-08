import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProgressKeluhan extends StatefulWidget {
  const ProgressKeluhan({super.key});

  @override
  State<ProgressKeluhan> createState() => _ProgressKeluhanState();
}

class _ProgressKeluhanState extends State<ProgressKeluhan> {
  List<dynamic> listLaporan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tarikData();
  }

  // Fungsi mengambil data dari database via API
  Future<void> _tarikData() async {
    var data = await ApiService.ambilSemuaLaporan();
    setState(() {
      // Membalik array agar laporan terbaru muncul di paling atas
      listLaporan = data.reversed.toList(); 
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text("Progress Keluhan", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)))
          : listLaporan.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _tarikData, // Fitur "Tarik ke bawah untuk refresh"
                  color: const Color(0xFF4A90E2),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listLaporan.length,
                    itemBuilder: (context, index) {
                      var laporan = listLaporan[index];
                      // Jika di tabel database belum ada kolom 'status', defaultkan 'Menunggu'
                      String statusLaporan = laporan['status'] ?? 'Menunggu'; 
                      return _buildProgressCard(
                        judul: laporan['judul'],
                        deskripsi: laporan['deskripsi'],
                        status: statusLaporan,
                      );
                    },
                  ),
                ),
    );
  }

  // UI Bantuan: Jika belum ada laporan sama sekali
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada keluhan yang diajukan", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  // UI Bantuan: Desain Kartu Laporan
  Widget _buildProgressCard({required String judul, required String deskripsi, required String status}) {
    // Menentukan warna badge (label) berdasarkan status
    Color statusColor;
    IconData statusIcon;

    if (status.toLowerCase() == 'selesai') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (status.toLowerCase() == 'diproses') {
      statusColor = Colors.blue;
      statusIcon = Icons.autorenew;
    } else {
      statusColor = Colors.orange; // Default untuk "Menunggu"
      statusIcon = Icons.pending_actions;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon Laporan Bulat
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                  child: const Icon(Icons.report_problem_rounded, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                
                // Judul & Deskripsi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(deskripsi, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            
            // Bagian Bawah: Label Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status Laporan:", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: statusColor)),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}