<?php

namespace Tests\Feature;

use App\Models\Laporan;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class LaporanDashboardTest extends TestCase
{
    use RefreshDatabase;

    public function test_dashboard_displays_reports(): void
    {
        $laporan = Laporan::create([
            'judul' => 'Kebocoran air',
            'deskripsi' => 'Ada genangan air di depan rumah.',
            'foto_path' => 'laporan_fotos/test.jpg',
            'latitude' => -6.200000,
            'longitude' => 106.816666,
            'status' => 'menunggu',
        ]);

        $response = $this->get('/');

        $response->assertStatus(200);
        $response->assertSee($laporan->judul);
        $response->assertSee($laporan->deskripsi);
        $response->assertSee('Kumpulan laporan');
    }
}
