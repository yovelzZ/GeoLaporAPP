<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DashboardController;

// Halaman utama langsung diarahkan ke Dashboard
Route::get('/', [DashboardController::class, 'index']);
Route::get('/admin/dashboard', [DashboardController::class, 'index']);

// Rute Sidebar
Route::get('/laporan', [DashboardController::class, 'dataPengaduan']);
Route::get('/laporan/menunggu', [DashboardController::class, 'belumDitindaklanjuti']);
Route::get('/laporan/proses', [DashboardController::class, 'dalamProses']);
Route::get('/laporan/selesai', [DashboardController::class, 'selesai']);
Route::get('/peta', [DashboardController::class, 'peta']);

// Rute untuk mengupdate status
Route::post('/update-status/{id}', [DashboardController::class, 'updateStatus'])->name('update.status');