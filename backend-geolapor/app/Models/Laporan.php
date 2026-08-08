<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Laporan extends Model
{
    use HasFactory;

    // Mengizinkan kolom-kolom ini diisi data dari luar
    protected $fillable = [
        'judul', 
        'deskripsi', 
        'foto_path', 
        'latitude', 
        'longitude', 
        'status'
    ];
}
