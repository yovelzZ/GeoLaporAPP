import 'package:flutter/material.dart';
import '../services/api_service.dart';

class KomentarBottomSheet extends StatefulWidget {
  final int laporanId;
  final Function(int count)? onKomentarUpdated;

  const KomentarBottomSheet({super.key, required this.laporanId, this.onKomentarUpdated});

  @override
  State<KomentarBottomSheet> createState() => _KomentarBottomSheetState();
}

class _KomentarBottomSheetState extends State<KomentarBottomSheet> {
  List<dynamic> listKomentar = [];
  bool isLoading = true;
  bool isSending = false;
  final TextEditingController _komentarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tarikKomentar();
  }

  Future<void> _tarikKomentar() async {
    final data = await ApiService.ambilKomentar(widget.laporanId);
    if (mounted) {
      setState(() {
        listKomentar = data;
        isLoading = false;
      });
      if (widget.onKomentarUpdated != null) {
        widget.onKomentarUpdated!(listKomentar.length);
      }
    }
  }

  Future<void> _kirimKomentar() async {
    String text = _komentarController.text.trim();
    if (text.isEmpty) return;

    setState(() => isSending = true);

    final result = await ApiService.kirimKomentar(widget.laporanId, text);
    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login terlebih dahulu untuk berkomentar!')),
        );
      }
    } else {
      _komentarController.clear();
      await _tarikKomentar();
    }

    if (mounted) {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Memberikan tinggi 80% layar agar leluasa
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 12),
                Text('Komentar (${listKomentar.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Divider(height: 1),

          // Daftar Komentar
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : listKomentar.isEmpty
                    ? const Center(
                        child: Text("Belum ada komentar.\nJadilah yang pertama berkomentar!", 
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: listKomentar.length,
                        itemBuilder: (context, index) {
                          var komen = listKomentar[index];
                          String pengirim = (komen['user'] != null) ? komen['user']['name'] : 'Warga';
                          String isi = komen['isi_komentar'] ?? '';
                          String tgl = komen['created_at'] != null ? komen['created_at'].substring(0, 10) : '';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[200],
                                  child: const Icon(Icons.person, size: 20, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(pengirim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                          const SizedBox(width: 8),
                                          Text(tgl, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(isi, style: const TextStyle(fontSize: 14)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),

          // Input Form (Bawah)
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
              left: 12, right: 12, top: 12
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _komentarController,
                    decoration: InputDecoration(
                      hintText: "Tulis komentar...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                isSending
                    ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())
                    : IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF4A90E2)),
                        onPressed: _kirimKomentar,
                      )
              ],
            ),
          )
        ],
      ),
    );
  }
}
