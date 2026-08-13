<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Laporan;
use Illuminate\Support\Facades\Storage;

class LaporanController extends Controller
{
    // Fungsi untuk mengambil semua data laporan (dipakai di Peta & Progress Flutter)
    public function index(Request $request)
    {
        $userId = $request->user('sanctum') ? $request->user('sanctum')->id : null;
        
        $laporan = Laporan::with(['user:id,name'])
            ->withCount('dukungans')
            ->withCount('komentars')
            ->orderBy('dukungans_count', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        if ($userId) {
            $laporan->map(function ($item) use ($userId) {
                $item->is_supported_by_me = $item->dukungans()->where('user_id', $userId)->exists();
                return $item;
            });
        } else {
            $laporan->map(function ($item) {
                $item->is_supported_by_me = false;
                return $item;
            });
        }

        return response()->json($laporan);
    }

    public function getKomentar($id)
    {
        $laporan = Laporan::findOrFail($id);
        $komentars = $laporan->komentars()->with('user:id,name')->orderBy('created_at', 'asc')->get();
        return response()->json($komentars);
    }

    public function storeKomentar(Request $request, $id)
    {
        $request->validate([
            'isi_komentar' => 'required|string|max:1000',
        ]);

        $laporan = Laporan::findOrFail($id);
        
        $komentar = $laporan->komentars()->create([
            'user_id' => $request->user()->id,
            'isi_komentar' => $request->isi_komentar,
        ]);

        $komentar->load('user:id,name');

        return response()->json([
            'message' => 'Komentar berhasil ditambahkan',
            'komentar' => $komentar
        ], 201);
    }

    // Fungsi untuk mendukung (Upvote) laporan
    public function dukung(Request $request, $id)
    {
        $laporan = Laporan::findOrFail($id);
        $userId = $request->user()->id;

        $dukungan = \App\Models\Dukungan::where('laporan_id', $id)
            ->where('user_id', $userId)
            ->first();

        if ($dukungan) {
            // Batal dukung (Toggle)
            $dukungan->delete();
            $status = 'unsupported';
        } else {
            // Tambah dukungan
            \App\Models\Dukungan::create([
                'user_id' => $userId,
                'laporan_id' => $id,
            ]);
            $status = 'supported';
        }

        return response()->json([
            'status' => $status,
            'dukungans_count' => $laporan->dukungans()->count()
        ]);
    }

    // Fungsi untuk mengambil laporan milik user yang sedang login
    public function myLaporans(Request $request)
    {
        $laporan = Laporan::where('user_id', $request->user()->id)->orderBy('created_at', 'desc')->get();
        return response()->json($laporan);
    }

    // Fungsi untuk Menerima data & foto dari Flutter
    public function store(Request $request)
    {
        try {
            $laporan = new Laporan();
            
            // Jika ada token (user login), catat user_id-nya
            if ($user = $request->user('sanctum')) {
                $laporan->user_id = $user->id;
            }

            $laporan->judul = $request->judul;
            $laporan->deskripsi = $request->deskripsi;
            $laporan->kategori = $request->kategori;
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