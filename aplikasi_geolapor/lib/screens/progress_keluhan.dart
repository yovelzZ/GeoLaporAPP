import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/komentar_bottom_sheet.dart';

class ProgressKeluhan extends StatefulWidget {
  const ProgressKeluhan({super.key});

  @override
  State<ProgressKeluhan> createState() => _ProgressKeluhanState();
}

class _ProgressKeluhanState extends State<ProgressKeluhan> {
  List<dynamic> listLaporan = []; // Data asli (semua)
  List<dynamic> _laporanDitampilkan = []; // Data yang sudah difilter
  bool isLoading = true;

  // Variabel untuk fitur filter
  String _filterAktif = 'Semua';
  final List<String> _pilihanFilter = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tarikData();
  }

  Future<void> _tarikData() async {
    setState(() => isLoading = true);
    var data = await ApiService.ambilSemuaLaporan();
    setState(() {
      listLaporan = data; 
      _terapkanFilter(_filterAktif); // Terapkan filter saat data baru masuk
      isLoading = false;
    });
  }

  // Fungsi Filter
  void _terapkanFilter(String filter) {
    setState(() {
      _filterAktif = filter;
      if (filter == 'Semua') {
        _laporanDitampilkan = List.from(listLaporan);
      } else {
        _laporanDitampilkan = listLaporan.where((laporan) {
          String status = laporan['status'] ?? 'Menunggu';
          return status.toLowerCase() == filter.toLowerCase();
        }).toList();
      }
    });
  }

  Future<void> _handleDukungan(int laporanId) async {
    final result = await ApiService.toggleDukungan(laporanId);
    
    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login untuk memberi dukungan!')),
        );
      }
      return;
    }

    setState(() {
      // Cari index dari data ASLI berdasarkan laporanId
      int originalIndex = listLaporan.indexWhere((l) => l['id'] == laporanId);
      if (originalIndex != -1) {
        listLaporan[originalIndex]['dukungans_count'] = result['dukungans_count'];
        listLaporan[originalIndex]['is_supported_by_me'] = result['status'] == 'supported';
        // Sinkronisasi data yang ditampilkan di layar
        _terapkanFilter(_filterAktif); 
      }
    });
  }

  void _bukaKomentar(int laporanId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KomentarBottomSheet(
        laporanId: laporanId,
        onKomentarUpdated: (newCount) {
          setState(() {
            int originalIndex = listLaporan.indexWhere((l) => l['id'] == laporanId);
            if (originalIndex != -1) {
              listLaporan[originalIndex]['komentars_count'] = newCount;
              _terapkanFilter(_filterAktif); // Sinkronisasi ulang
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: const Text(
          "Keluhan Warga", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 22)
        ),
      ),
      body: Column(
        children: [
          // --- BAGIAN FILTER UI ---
          Container(
            color: Colors.white,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pilihanFilter.length,
              itemBuilder: (context, index) {
                final filter = _pilihanFilter[index];
                final isSelected = _filterAktif == filter;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                  child: ChoiceChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.black87 : Colors.black54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        _terapkanFilter(filter);
                      }
                    },
                    selectedColor: const Color(0xFF1E88E5), // Warna cream
                    backgroundColor: const Color(0xFFF0F2F5),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // --- BAGIAN DAFTAR KELUHAN ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)))
                : _laporanDitampilkan.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _tarikData,
                        color: const Color(0xFF4A90E2),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemCount: _laporanDitampilkan.length, // Gunakan list yang sudah difilter
                          itemBuilder: (context, index) {
                            var laporan = _laporanDitampilkan[index];
                            return _buildProgressCard(laporan);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _filterAktif == 'Semua' 
              ? "Belum ada keluhan yang diajukan" 
              : "Tidak ada keluhan dengan status '$_filterAktif'", 
            style: const TextStyle(color: Colors.grey, fontSize: 16)
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(dynamic laporan) { // Index dihapus karena tidak lagi relevan secara UI
    String judul = laporan['judul'] ?? '';
    String deskripsi = laporan['deskripsi'] ?? '';
    String status = laporan['status'] ?? 'Menunggu';
    int dukunganCount = laporan['dukungans_count'] ?? 0;
    int komentarCount = laporan['komentars_count'] ?? 0;
    bool isSupported = laporan['is_supported_by_me'] ?? false;
    String kategori = laporan['kategori'] ?? 'Lainnya';
    String foto = laporan['foto'] ?? '';
    String pelapor = (laporan['user'] != null && laporan['user']['name'] != null) 
                      ? laporan['user']['name'] 
                      : 'Warga Anonim';

    String tanggalRaw = laporan['created_at'] ?? '';
    String tanggal = "Baru saja";
    if (tanggalRaw.length > 10) {
      tanggal = tanggalRaw.substring(0, 10);
    }

    String fotoUrl = '';
    if (foto.isNotEmpty) {
      fotoUrl = ApiService.baseUrl.replaceAll('/api', '/storage/') + foto;
    }

    Color statusColor;
    if (status.toLowerCase() == 'selesai') {
      statusColor = const Color(0xFF10B981); // Emerald
    } else if (status.toLowerCase() == 'diproses') {
      statusColor = const Color(0xFF3B82F6); // Blue
    } else {
      statusColor = const Color(0xFFF59E0B); // Amber
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 20,
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pelapor, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
                      ),
                      Row(
                        children: [
                          Text(tanggal, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          const SizedBox(width: 6),
                          const Text("•", style: TextStyle(color: Colors.grey, fontSize: 10)),
                          const SizedBox(width: 6),
                          Text(kategori, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                )
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  deskripsi, 
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ],
            ),
          ),

          if (fotoUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              color: Colors.grey[100],
              child: Image.network(
                fotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _handleDukungan(laporan['id']), // Cukup gunakan laporanId
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSupported ? Colors.red.withOpacity(0.1) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSupported ? Icons.local_fire_department : Icons.local_fire_department_outlined, 
                          size: 20, 
                          color: isSupported ? Colors.red : Colors.grey[700]
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dukunganCount > 0 ? '$dukunganCount' : 'Dukung',
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold, 
                            color: isSupported ? Colors.red : Colors.grey[700]
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _bukaKomentar(laporan['id']), // Cukup gunakan laporanId
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 6),
                        Text(
                          komentarCount > 0 ? '$komentarCount' : 'Komentar', 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.share_outlined, size: 20, color: Colors.grey[700]),
                  onPressed: () {},
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}