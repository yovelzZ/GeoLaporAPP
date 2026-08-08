<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Laporan;
use Illuminate\Support\Facades\Storage;

class LaporanController extends Controller
{
    // Fungsi untuk mengambil semua data laporan (dipakai di Peta & Progress Flutter)
    public function index()
    {
        $laporan = Laporan::orderBy('created_at', 'desc')->get();
        return response()->json($laporan);
    }

    // Fungsi untuk Menerima data & foto dari Flutter
    public function store(Request $request)
    {
        try {
            $laporan = new Laporan();
            $laporan->judul = $request->judul;
            $laporan->deskripsi = $request->deskripsi;
            $laporan->latitude = $request->latitude;
            $laporan->longitude = $request->longitude;
            $laporan->status = 'Menunggu'; // Status otomatis saat baru lapor

            // PROSES SIMPAN FOTO
            // Kunci 'foto' ini harus sama persis dengan yang dikirim dari Flutter
            if ($request->hasFile('foto')) {
                // Simpan ke folder storage/app/public/laporan
                $path = $request->file('foto')->store('laporan', 'public');
                $laporan->foto = $path;
            }

            $laporan->save();

            return response()->json([
                'status' => 'success',
                'message' => 'Laporan berhasil dikirim'
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menyimpan laporan: ' . $e->getMessage()
            ], 500);
        }
    }
}