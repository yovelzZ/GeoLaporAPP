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
        $laporans = Laporan::withCount('dukungans')->orderBy('dukungans_count', 'desc')->orderBy('created_at', 'desc')->get();
        
        // Data untuk Grafik Jumlah Pengaduan per Bulan (Tahun Ini)
        $chartData = Laporan::selectRaw('MONTH(created_at) as month, COUNT(*) as count')
            ->whereYear('created_at', date('Y'))
            ->groupBy('month')
            ->pluck('count', 'month')->toArray();
            
        $monthlyCounts = array_fill(1, 12, 0);
        foreach ($chartData as $month => $count) {
            $monthlyCounts[$month] = $count;
        }

        // Jumlah kategori unik
        $kategoriCount = Laporan::whereNotNull('kategori')->distinct('kategori')->count('kategori');

        // Data untuk Heatmap (Laporan yang belum selesai)
        $activeLaporans = Laporan::where('status', '!=', 'Selesai')->get(['latitude', 'longitude', 'status']);

        return view('dashboard', compact('laporans', 'monthlyCounts', 'kategoriCount', 'activeLaporans'));
    }

    // Fungsi untuk petugas memperbarui status laporan
    public function updateStatus(Request $request, $id)
    {
        $laporan = Laporan::findOrFail($id);
        $laporan->status = $request->status;
        $laporan->save();

        return redirect()->back()->with('success', 'Status laporan berhasil diperbarui!');
    }

    public function dataPengaduan()
    {
        $laporans = Laporan::withCount('dukungans')->orderBy('dukungans_count', 'desc')->orderBy('created_at', 'desc')->get();
        return view('pages.pengaduan', compact('laporans'))->with('title', 'Data Pengaduan');
    }

    public function belumDitindaklanjuti()
    {
        $laporans = Laporan::withCount('dukungans')->where('status', 'Menunggu')->orderBy('dukungans_count', 'desc')->orderBy('created_at', 'desc')->get();
        return view('pages.pengaduan', compact('laporans'))->with('title', 'Belum Ditindaklanjuti');
    }

    public function dalamProses()
    {
        $laporans = Laporan::withCount('dukungans')->where('status', 'Diproses')->orderBy('dukungans_count', 'desc')->orderBy('created_at', 'desc')->get();
        return view('pages.pengaduan', compact('laporans'))->with('title', 'Dalam Proses');
    }

    public function selesai()
    {
        $laporans = Laporan::withCount('dukungans')->where('status', 'Selesai')->orderBy('dukungans_count', 'desc')->orderBy('created_at', 'desc')->get();
        return view('pages.pengaduan', compact('laporans'))->with('title', 'Selesai');
    }

    public function peta()
    {
        $laporans = Laporan::orderBy('created_at', 'desc')->get();
        $activeLaporans = Laporan::where('status', '!=', 'Selesai')->get(['latitude', 'longitude', 'status']);
        return view('pages.peta', compact('laporans', 'activeLaporans'));
    }
}