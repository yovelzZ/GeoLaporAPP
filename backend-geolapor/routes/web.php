<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DashboardController;

// Halaman utama langsung diarahkan ke Dashboard
Route::get('/', [DashboardController::class, 'index']);

// Rute untuk mengupdate status
Route::post('/update-status/{id}', [DashboardController::class, 'updateStatus'])->name('update.status');