<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
public function up(): void
    {
        Schema::create('laporans', function (Blueprint $table) {
            $table->id();
            $table->string('judul');
            $table->text('deskripsi');
            $table->string('foto_path'); // Menyimpan nama/lokasi file foto
            $table->double('latitude');  // Menyimpan koordinat garis lintang
            $table->double('longitude'); // Menyimpan koordinat garis bujur
            $table->string('status')->default('menunggu'); // Status default: menunggu diproses
            $table->timestamps();
        });
    }
};
