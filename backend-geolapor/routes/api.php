<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LaporanController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// URL untuk mengambil data laporan (Method: GET)
Route::get('/laporan', [LaporanController::class, 'index']);

// URL untuk mengirim data laporan baru (Method: POST)
Route::post('/laporan', [LaporanController::class, 'store']);