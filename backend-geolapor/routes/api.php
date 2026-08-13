<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\LaporanController;

use App\Http\Controllers\AuthController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/laporan', [LaporanController::class, 'index']);
Route::get('/laporan/{id}/komentar', [LaporanController::class, 'getKomentar']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/user/update', [AuthController::class, 'updateProfile']);
    Route::get('/laporan/me', [LaporanController::class, 'myLaporans']);
    Route::post('/laporan/{id}/dukung', [LaporanController::class, 'dukung']);
    Route::post('/laporan/{id}/komentar', [LaporanController::class, 'storeKomentar']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});

// URL untuk mengambil data laporan umum (Method: GET)
Route::get('/laporan', [LaporanController::class, 'index']);

// URL untuk mengirim data laporan baru (Guest & User, Method: POST)
Route::post('/laporan', [LaporanController::class, 'store']);