@extends('layouts.admin')

@section('title', 'Dashboard')

@push('css')
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet.locatecontrol@0.79.0/dist/L.Control.Locate.min.css" />
    <style>
        /* Card Styling */
        .glass-card {
            background: white;
            border-radius: 12px;
            border: none;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            padding: 20px;
            margin-bottom: 20px;
        }

        .stat-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .stat-card .icon-box {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        /* Ikon spesifik */
        .icon-total { background: #EEF2FF; color: #6366F1; }
        .icon-menunggu { background: #FFF7ED; color: #F97316; }
        .icon-selesai { background: #F0FDF4; color: #22C55E; }
        .icon-kategori { background: #F0F9FF; color: #0EA5E9; }

        .stat-card h3 {
            margin: 0;
            font-weight: 700;
            font-size: 28px;
        }

        .stat-card p {
            margin: 0;
            color: #64748B;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
        }

        /* Chart & Map Container */
        #map {
            height: 350px;
            border-radius: 10px;
            z-index: 1;
        }
        
        .chart-container {
            height: 350px;
            width: 100%;
        }
        
        .table-custom th {
            font-size: 13px;
            color: #64748B;
            font-weight: 600;
            background: #F8FAFC;
            border-bottom: 1px solid #E2E8F0;
        }
        
        .table-custom td {
            font-size: 14px;
            vertical-align: middle;
        }

        /* Legend Heatmap */
        .info.legend {
            background: white;
            padding: 8px 12px;
            font-size: 12px;
            line-height: 1.5;
            color: #555;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0,0,0,0.1);
        }
        .info.legend i {
            width: 15px;
            height: 15px;
            float: left;
            margin-right: 8px;
            opacity: 0.8;
            border-radius: 50%;
        }
    </style>
@endpush

@section('content')
<div class="container-fluid p-0">
    
    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i> {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif

    <!-- 4 STAT CARDS -->
    <div class="row">
        <!-- TOTAL PENGADUAN -->
        <div class="col-md-3">
            <div class="glass-card stat-card">
                <div>
                    <p>TOTAL PENGADUAN</p>
                    <h3>{{ $laporans->count() }}</h3>
                </div>
                <div class="icon-box icon-total">
                    <i class="bi bi-inbox-fill"></i>
                </div>
            </div>
        </div>

        <!-- BELUM DITINDAKLANJUTI -->
        <div class="col-md-3">
            <div class="glass-card stat-card">
                <div>
                    <p>BELUM DITINDAKLANJUTI</p>
                    <h3>{{ $laporans->where('status', 'Menunggu')->count() }}</h3>
                </div>
                <div class="icon-box icon-menunggu">
                    <i class="bi bi-clock-fill"></i>
                </div>
            </div>
        </div>

        <!-- SUDAH SELESAI -->
        <div class="col-md-3">
            <div class="glass-card stat-card">
                <div>
                    <p>SUDAH SELESAI</p>
                    <h3>{{ $laporans->where('status', 'Selesai')->count() }}</h3>
                </div>
                <div class="icon-box icon-selesai">
                    <i class="bi bi-check-circle-fill"></i>
                </div>
            </div>
        </div>

        <!-- KATEGORI INFRASTRUKTUR -->
        <div class="col-md-3">
            <div class="glass-card stat-card">
                <div>
                    <p>KATEGORI INFRASTRUKTUR</p>
                    <h3>{{ $kategoriCount }}</h3>
                </div>
                <div class="icon-box icon-kategori">
                    <i class="bi bi-cone-striped"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- CHART DAN PETA -->
    <div class="row">
        <!-- GRAFIK -->
        <div class="col-md-6">
            <div class="glass-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="fw-bold mb-0">Grafik Jumlah Pengaduan per Bulan</h6>
                    <select class="form-select form-select-sm w-auto">
                        <option>{{ date('Y') }}</option>
                    </select>
                </div>
                <div class="chart-container">
                    <canvas id="pengaduanChart"></canvas>
                </div>
            </div>
        </div>

        <!-- PETA -->
        <div class="col-md-6">
            <div class="glass-card">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="fw-bold mb-0">Peta Persebaran Laporan</h6>
                    <a href="{{ url('/peta') }}" class="btn btn-sm btn-outline-primary"><i class="bi bi-arrows-fullscreen"></i> PERBESAR</a>
                </div>
                <div id="map"></div>
            </div>
        </div>
    </div>

    <!-- TABEL LAPORAN TERBARU -->
    <div class="row mt-2">
        <div class="col-12">
            <div class="glass-card">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h6 class="fw-bold mb-0">Laporan Kerusakan Terbaru</h6>
                    <a href="{{ url('/laporan') }}" class="btn btn-sm btn-outline-primary">LIHAT SEMUA</a>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-hover table-custom">
                        <thead>
                            <tr>
                                <th>Kategori</th>
                                <th>Judul Laporan</th>
                                <th>Tanggal</th>
                                <th>Dukungan</th>
                                <th>Lokasi (Gmaps)</th>
                                <th>Status</th>
                                <th>Aksi</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($laporans->take(5) as $item)
                            <tr>
                                <td class="fw-medium">{{ $item->kategori ?? 'Lainnya' }}</td>
                                <td>{{ Str::limit($item->judul, 40) }}</td>
                                <td>{{ $item->created_at->format('d M Y') }}</td>
                                <td>
                                    <span class="badge bg-danger bg-opacity-10 text-danger px-2 py-1 rounded">
                                        <i class="bi bi-fire"></i> {{ $item->dukungans_count ?? 0 }}
                                    </span>
                                </td>
                                <td>
                                    <small class="text-muted"><i class="bi bi-geo-alt-fill text-danger"></i> <span class="lokasi-text-dash" data-lat="{{ $item->latitude }}" data-lng="{{ $item->longitude }}">Memuat alamat...</span></small>
                                    <br>
                                    <a href="https://www.google.com/maps?q={{ $item->latitude }},{{ $item->longitude }}" target="_blank" class="btn btn-sm btn-outline-danger mt-1" style="font-size: 10px; padding: 2px 6px;">
                                        <i class="bi bi-map"></i> Maps
                                    </a>
                                </td>
                                <td>
                                    @if(strtolower($item->status) == 'selesai')
                                        <span class="badge bg-success bg-opacity-10 text-success px-2 py-1 rounded">Selesai</span>
                                    @elseif(strtolower($item->status) == 'diproses')
                                        <span class="badge bg-primary bg-opacity-10 text-primary px-2 py-1 rounded">Proses</span>
                                    @else
                                        <span class="badge bg-warning bg-opacity-10 text-warning px-2 py-1 rounded">Menunggu</span>
                                    @endif
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-light shadow-sm" data-bs-toggle="modal" data-bs-target="#modalDetail{{ $item->id }}">
                                        <i class="bi bi-eye-fill"></i>
                                    </button>
                                </td>
                            </tr>
                            
                            <!-- Modal Detail -->
                            <div class="modal fade" id="modalDetail{{ $item->id }}" tabindex="-1">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Ubah Status Laporan</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <p><strong>{{ $item->judul }}</strong></p>
                                            <p>{{ $item->deskripsi }}</p>
                                            <form action="{{ route('update.status', $item->id) }}" method="POST">
                                                @csrf
                                                <div class="mb-3">
                                                    <label class="form-label">Status saat ini</label>
                                                    <select name="status" class="form-select">
                                                        <option value="Menunggu" {{ $item->status == 'Menunggu' ? 'selected' : '' }}>Menunggu</option>
                                                        <option value="Diproses" {{ $item->status == 'Diproses' ? 'selected' : '' }}>Diproses</option>
                                                        <option value="Selesai" {{ $item->status == 'Selesai' ? 'selected' : '' }}>Selesai</option>
                                                    </select>
                                                </div>
                                                <button type="submit" class="btn btn-primary w-100">Simpan Perubahan</button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            @empty
                            <tr>
                                <td colspan="5" class="text-center text-muted py-4">Belum ada data laporan.</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<!-- Leaflet JS & Plugin -->
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/leaflet.locatecontrol@0.79.0/dist/L.Control.Locate.min.js"></script>
<!-- Leaflet Heatmap -->
<script src="https://unpkg.com/leaflet.heat@0.2.0/dist/leaflet-heat.js"></script>

<script>
    // Inisialisasi Chart.js
    const ctx = document.getElementById('pengaduanChart').getContext('2d');
    
    // Data dari Controller
    const monthlyData = @json(array_values($monthlyCounts));
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
            datasets: [{
                label: 'Jumlah Pengaduan',
                data: monthlyData,
                borderColor: '#3b82f6',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                borderWidth: 2,
                pointBackgroundColor: '#3b82f6',
                pointBorderColor: '#fff',
                pointRadius: 4,
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: { color: '#f1f5f9' },
                    ticks: { precision: 0 }
                },
                x: {
                    grid: { display: false }
                }
            }
        }
    });

    // Inisialisasi Peta Leaflet
    const map = L.map('map').setView([5.1802, 97.1507], 13); // Default Lhokseumawe/Aceh (sesuai gambar)
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap contributors'
    }).addTo(map);
    
    // Tambahkan tombol GPS / Locate
    L.control.locate({
        position: 'topleft',
        strings: {
            title: "Tunjukkan lokasi saya!"
        },
        locateOptions: {
            enableHighAccuracy: true
        }
    }).addTo(map);

    // Minta browser untuk fokus ke lokasi user saat halaman diload
    map.locate({setView: true, maxZoom: 15});

    // Marker dari data laporans
    const laporans = @json($laporans);
    laporans.forEach(item => {
        if (item.latitude && item.longitude) {
            let marker = L.marker([item.latitude, item.longitude]).addTo(map);
            
            let popupContent = `
                <div style="min-width: 200px;">
                    <b style="font-size:14px; color:#333;">${item.kategori || 'Lainnya'}</b><br>
                    <span style="font-size:13px; color:#555;">${item.judul}</span><br>
                    <hr style="margin:8px 0; border:0; border-top:1px solid #eee;">
                    <span id="alamat-dash-${item.id}" style="font-size:12px; color:#777;"><i>📍 Memuat alamat...</i></span><br>
                    <a href="https://www.google.com/maps?q=${item.latitude},${item.longitude}" target="_blank" 
                       style="display:inline-block; margin-top:10px; padding:6px 12px; background:#e74c3c; color:white; text-decoration:none; border-radius:6px; font-size:12px; font-weight:bold; width:100%; text-align:center;">
                       🗺️ Buka di Google Maps
                    </a>
                </div>
            `;
            
            marker.bindPopup(popupContent);
            
            marker.on('popupopen', function() {
                const alamatSpan = document.getElementById(`alamat-dash-${item.id}`);
                if(alamatSpan && alamatSpan.innerHTML.includes('Memuat')) {
                    fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${item.latitude}&lon=${item.longitude}`)
                    .then(res => res.json())
                    .then(data => {
                        alamatSpan.innerHTML = `📍 ${data.display_name || "Alamat tidak ditemukan"}`;
                    })
                    .catch(err => {
                        alamatSpan.innerHTML = "📍 Gagal memuat alamat";
                    });
                }
            });
        }
    });

    // Zona Merah (Heatmap)
    const activeLaporans = @json($activeLaporans);
    const heatPoints = activeLaporans
        .filter(item => item.latitude && item.longitude)
        .map(item => [item.latitude, item.longitude, 1.0]); // 1.0 adalah intensitas

    if (heatPoints.length > 0) {
        L.heatLayer(heatPoints, {
            radius: 25,
            blur: 15,
            maxZoom: 17,
            max: 5.0, // Batas maksimal intensitas (misal 5 laporan tumpang tindih = merah murni)
            gradient: {0.4: 'blue', 0.6: 'cyan', 0.7: 'lime', 0.8: 'yellow', 1.0: 'red'}
        }).addTo(map);
    }

    // Menambahkan Keterangan Warna (Legend) ke dalam peta
    const legend = L.control({position: 'bottomright'});
    legend.onAdd = function (map) {
        const div = L.DomUtil.create('div', 'info legend');
        div.innerHTML += '<h6 style="font-size:12px;font-weight:bold;margin-bottom:8px;">Intensitas Rawan<br><small style="font-weight:normal">(Radius 25px)</small></h6>';
        div.innerHTML += '<i style="background: blue"></i> Rendah (1-2 Laporan)<br>';
        div.innerHTML += '<i style="background: lime"></i> Sedang (3-4 Laporan)<br>';
        div.innerHTML += '<i style="background: red"></i> Tinggi (≥5 Laporan)<br>';
        return div;
    };
    legend.addTo(map);

    // Geocoding untuk Tabel Dashboard
    document.addEventListener("DOMContentLoaded", function() {
        const lokasiElements = document.querySelectorAll('.lokasi-text-dash');
        lokasiElements.forEach((el, index) => {
            const lat = el.getAttribute('data-lat');
            const lng = el.getAttribute('data-lng');
            
            setTimeout(() => {
                fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`)
                    .then(response => response.json())
                    .then(data => {
                        el.innerText = data.display_name ? data.display_name : "Alamat tidak ditemukan";
                    })
                    .catch(error => {
                        el.innerText = `Lat: ${lat}, Lng: ${lng}`;
                    });
            }, index * 1000); 
        });
    });

</script>
@endpush