import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQR extends StatefulWidget {
  const ScanQR({super.key});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> {
  // Inisialisasi controller scanner
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true; // Mengunci scanner agar tidak spam saat QR terbaca

  @override
  void dispose() {
    cameraController.dispose(); // Mematikan kamera saat keluar halaman
    super.dispose();
  }

  // Fungsi saat QR Code berhasil terbaca
  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return; // Jika sedang memproses, abaikan scan lain

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => isScanning = false); // Kunci scanner
        final String hasilScan = barcode.rawValue!;
        
        // Memunculkan Pop-up hasil
        _tampilkanHasilDialog(hasilScan);
        break; // Hentikan looping
      }
    }
  }

  void _tampilkanHasilDialog(String hasil) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Column(
            children: [
              Icon(Icons.qr_code_scanner, size: 50, color: Color(0xFF4A90E2)),
              SizedBox(height: 10),
              Text("QR Berhasil Dipindai!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text(
            hasil, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup Pop-up
                  // Beri jeda sedikit, lalu buka kunci scanner lagi
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() => isScanning = true);
                  });
                },
                child: const Text("Scan Ulang", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Scan QR Fasilitas", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // Tombol Senter (Flashlight) - Telah Diperbarui untuk versi 7+
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: cameraController,
              builder: (context, state, child) {
                if (state.torchState == TorchState.on) {
                  return const Icon(Icons.flash_on, color: Colors.yellow);
                }
                return const Icon(Icons.flash_off, color: Colors.grey);
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Widget Kamera Pindai
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          
          // Efek Overlay Gelap dengan Kotak Transparan di Tengah
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.srcOut),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.black),
                  ),
                ),
                Center(
                  child: Container(
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      color: Colors.black, // Membuat bagian tengah transparan (efek BlendMode)
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Garis Sudut Pembidik (Hiasan)
          Center(
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          
          // Teks Petunjuk
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Text(
              "Arahkan kamera ke QR Code\npada fasilitas umum",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}