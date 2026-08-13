<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Laporan extends Model
{
    use HasFactory;

    // Mengizinkan kolom-kolom ini diisi data dari luar
    protected $fillable = [
        'user_id',
        'judul',
        'deskripsi',
        'kategori',
        'foto',
        'latitude',
        'longitude',
        'status',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function dukungans()
    {
        return $this->hasMany(Dukungan::class);
    }

    public function komentars()
    {
        return $this->hasMany(Komentar::class);
    }
}
