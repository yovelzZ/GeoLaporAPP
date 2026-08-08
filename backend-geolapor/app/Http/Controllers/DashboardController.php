<?php

namespace App\Http\Controllers;

use App\Models\Laporan; // Pastikan model Laporan terpanggil
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    // Fungsi untuk menampilkan halaman dashboard utama
    public function index()
    {
        // Mengambil semua data laporan, diurutkan dari yang terbaru
        $laporans = Laporan::orderBy('created_at', 'desc')->get();
        return view('dashboard', compact('laporans'));
    }

    // Fungsi untuk petugas memperbarui status laporan
    public function updateStatus(Request $request, $id)
    {
        $laporan = Laporan::findOrFail($id);
        $laporan->status = $request->status;
        $laporan->save();

        return redirect()->back()->with('success', 'Status laporan berhasil diperbarui!');
    }
}