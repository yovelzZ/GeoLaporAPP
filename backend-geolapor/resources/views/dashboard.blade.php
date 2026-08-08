<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - GeoLapor</title>

    <!-- Google Fonts: Poppins -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <!-- DataTables CSS (Untuk Tabel Canggih) -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
    <!-- Animate.css (Untuk Efek Animasi Muncul) -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css"/>

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #F4F7FE; /* Warna background abu kebiruan modern */
            color: #2B3674;
        }
        /* Navbar Modern Gradient */
        .navbar-custom {
            background: linear-gradient(135deg, #4A90E2 0%, #00B4DB 100%);
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            padding: 15px 0;
        }
        /* Card & Panel Kaca (Glassmorphism ringan) */
        .glass-card {
            background: white;
            border-radius: 20px;
            border: none;
            box-shadow: 0 10px 30px rgba(112, 144, 176, 0.12);
            transition: transform 0.3s ease;
        }
        .glass-card:hover {
            transform: translateY(-5px); /* Efek melayang saat kursor menyorot */
        }
        /* Ikon pada Summary Card */
        .summary-icon {
            width: 55px;
            height: 55px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 26px;
        }
        /* Tombol Modern */
        .btn-modern {
            border-radius: 10px;
            font-weight: 500;
            transition: all 0.3s;
        }
        .btn-modern:hover {
            transform: scale(1.05);
        }
        /* Soft Badge untuk Status (Warna Pastel kekinian) */
        .badge-soft-warning { background-color: #FFF4DE; color: #FFA800; }
        .badge-soft-primary { background-color: #E1E9FF; color: #3E82F7; }
        .badge-soft-success { background-color: #E8FFF3; color: #00C689; }
        .badge-custom {
            padding: 8px 12px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 12px;
        }
        /* Thumbnail Gambar dengan Efek Hover */
        .img-thumbnail-custom {
            border-radius: 12px;
            transition: transform 0.3s;
            cursor: pointer;
        }
        .img-thumbnail-custom:hover {
            transform: scale(1.1);
        }
        /* Mempercantik border tabel */
        table.dataTable { border-collapse: collapse !important; }
        .table>:not(caption)>*>* { padding: 1rem 0.5rem; }
    </style>
</head>
<body>

    <!-- NAVBAR UTAMA -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-custom animate__animated animate__fadeInDown">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold" href="#"><i class="bi bi-geo-alt-fill text-warning"></i> GeoLapor Command Center</a>
            <div class="d-flex align-items-center">
                <span class="text-white me-3"><i class="bi bi-person-circle"></i> Halo, Administrator</span>
                <button class="btn btn-light btn-sm btn-modern text-primary"><i class="bi bi-box-arrow-right"></i> Keluar</button>
            </div>
        </div>
    </nav>

    <div class="container-fluid px-4 py-4">
        
        <!-- ALERT SUKSES BERHASIL UPDATE -->
        @if(session('success'))
            <div class="alert alert-success alert-dismissible fade show shadow-sm animate__animated animate__fadeInRight" role="alert" style="border-radius: 15px; border-left: 5px solid #00C689;">
                <i class="bi bi-check-circle-fill me-2"></i> {{ session('success') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        @endif

        <!-- WIDGET STATISTIK (Dihitung otomatis oleh sistem) -->
        <div class="row mb-4 animate__animated animate__fadeInUp">
            <!-- Card 1: Total -->
            <div class="col-md-3">
                <div class="card glass-card p-3 d-flex flex-row align-items-center">
                    <div class="summary-icon bg-light text-primary me-3 shadow-sm">
                        <i class="bi bi-file-earmark-text-fill"></i>
                    </div>
                    <div>
                        <h6 class="text-muted mb-1" style="font-size: 13px;">Total Laporan Masuk</h6>
                        <h3 class="mb-0 fw-bold">{{ $laporans->count() }}</h3>
                    </div>
                </div>
            </div>
            <!-- Card 2: Menunggu -->
            <div class="col-md-3">
                <div class="card glass-card p-3 d-flex flex-row align-items-center">
                    <div class="summary-icon bg-light text-warning me-3 shadow-sm">
                        <i class="bi bi-hourglass-split"></i>
                    </div>
                    <div>
                        <h6 class="text-muted mb-1" style="font-size: 13px;">Laporan Menunggu</h6>
                        <h3 class="mb-0 fw-bold">{{ $laporans->where('status', 'Menunggu')->count() }}</h3>
                    </div>
                </div>
            </div>
            <!-- Card 3: Diproses -->
            <div class="col-md-3">
                <div class="card glass-card p-3 d-flex flex-row align-items-center">
                    <div class="summary-icon bg-light text-info me-3 shadow-sm">
                        <i class="bi bi-gear-fill"></i>
                    </div>
                    <div>
                        <h6 class="text-muted mb-1" style="font-size: 13px;">Sedang Diproses</h6>
                        <h3 class="mb-0 fw-bold">{{ $laporans->where('status', 'Diproses')->count() }}</h3>
                    </div>
                </div>
            </div>
            <!-- Card 4: Selesai -->
            <div class="col-md-3">
                <div class="card glass-card p-3 d-flex flex-row align-items-center">
                    <div class="summary-icon bg-light text-success me-3 shadow-sm">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <div>
                        <h6 class="text-muted mb-1" style="font-size: 13px;">Selesai Diperbaiki</h6>
                        <h3 class="mb-0 fw-bold">{{ $laporans->where('status', 'Selesai')->count() }}</h3>
                    </div>
                </div>
            </div>
        </div>

        <!-- TABEL DATA UTAMA -->
        <div class="card glass-card p-4 animate__animated animate__fadeInUp" style="animation-delay: 0.2s;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h5 class="fw-bold"><i class="bi bi-table text-primary me-2"></i> Manajemen Data Keluhan Warga</h5>
                <button class="btn btn-primary btn-modern shadow-sm" onclick="location.reload();"><i class="bi bi-arrow-clockwise"></i> Segarkan Data</button>
            </div>
            
            <div class="table-responsive">
                <table id="tabelLaporan" class="table table-hover align-middle w-100">
                    <thead class="table-light">
                        <tr>
                            <th class="text-center">No</th>
                            <th>Foto Bukti</th>
                            <th>Detail Keluhan</th>
                            <th class="text-center">Titik Lokasi</th>
                            <th class="text-center">Status</th>
                            <th class="text-center">Tindakan</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($laporans as $index => $item)
                        <tr>
                            <td class="text-center fw-bold text-muted">{{ $index + 1 }}</td>
                            <td>
                                @if($item->foto)
                                    <!-- Jika ada foto, tampilkan dan bersihkan awalan 'public/' jika ada -->
                                    <img src="{{ asset('storage/' . str_replace('public/', '', $item->foto)) }}" class="img-thumbnail-custom shadow-sm" style="width: 80px; height: 80px; object-fit: cover;" data-bs-toggle="modal" data-bs-target="#fotoModal{{ $item->id }}" title="Klik untuk memperbesar">
                                @else
                                    <!-- Jika tidak ada foto (kosong), tampilkan kotak abu-abu -->
                                    <div class="bg-light rounded d-flex justify-content-center align-items-center shadow-sm" style="width: 80px; height: 80px;" title="Tidak ada foto">
                                        <i class="bi bi-camera-fill text-secondary fs-3"></i>
                                    </div>
                                @endif
                            </td>
                            <td>
                                <h6 class="fw-bold text-dark mb-1">{{ $item->judul }}</h6>
                                <p class="text-muted mb-1" style="font-size: 13px;">{{ Str::limit($item->deskripsi, 80) }}</p>
                                <span class="text-secondary" style="font-size: 11px;"><i class="bi bi-calendar-event text-primary"></i> Masuk pada: {{ $item->created_at->format('d M Y, H:i') }}</span>
                            </td>
                            <td class="text-center">
                                <a href="https://www.google.com/maps/search/?api=1&query={{ $item->latitude }},{{ $item->longitude }}" target="_blank" class="btn btn-sm btn-light btn-modern text-danger shadow-sm">
                                    <i class="bi bi-pin-map-fill"></i> Buka Peta
                                </a>
                            </td>
                            <td class="text-center">
                                @if(strtolower($item->status) == 'selesai')
                                    <span class="badge badge-custom badge-soft-success"><i class="bi bi-check-circle"></i> Selesai</span>
                                @elseif(strtolower($item->status) == 'diproses')
                                    <span class="badge badge-custom badge-soft-primary"><i class="bi bi-gear"></i> Diproses</span>
                                @else
                                    <span class="badge badge-custom badge-soft-warning"><i class="bi bi-hourglass-split"></i> Menunggu</span>
                                @endif
                            </td>
                            <td>
                                <!-- Form Ubah Status -->
                                <form action="{{ route('update.status', $item->id) }}" method="POST" class="d-flex justify-content-center gap-2">
                                    @csrf
                                    <select name="status" class="form-select form-select-sm" style="border-radius: 8px; width: 130px; border-color: #E2E8F0;">
                                        <option value="Menunggu" {{ $item->status == 'Menunggu' ? 'selected' : '' }}>Menunggu</option>
                                        <option value="Diproses" {{ $item->status == 'Diproses' ? 'selected' : '' }}>Diproses</option>
                                        <option value="Selesai" {{ $item->status == 'Selesai' ? 'selected' : '' }}>Selesai</option>
                                    </select>
                                    <button type="submit" class="btn btn-sm btn-success btn-modern shadow-sm" title="Simpan Status"><i class="bi bi-floppy-fill"></i></button>
                                </form>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- DI SINI TEMPAT BARU UNTUK MODAL (DI LUAR TABEL) -->
    @foreach($laporans as $item)
        <!-- Modal Pop-up Foto Membesar -->
        <div class="modal fade" id="fotoModal{{ $item->id }}" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content" style="border-radius: 20px; border: none; background: rgba(255,255,255,0.95); backdrop-filter: blur(10px);">
                    <div class="modal-header border-0 pb-0">
                        <h5 class="fw-bold ms-2 mt-2">{{ $item->judul }}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center pb-4">
                        @if($item->foto)
                            <img src="{{ asset('storage/' . str_replace('public/', '', $item->foto)) }}" class="img-fluid rounded shadow-lg" style="max-height: 500px; width: auto; object-fit: contain;">
                        @else
                            <div class="py-5">
                                <i class="bi bi-image text-muted" style="font-size: 80px;"></i>
                                <h5 class="text-muted mt-3">Tidak ada foto bukti yang dilampirkan</h5>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
        <!-- End Modal -->
    @endforeach

    <!-- SCRIPT LIBRARY -->
    <!-- jQuery (Dibutuhkan oleh DataTables) -->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <!-- Bootstrap Bundle JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- DataTables Core & Bootstrap 5 Integration -->
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
    
    <!-- Inisialisasi DataTables -->
    <script>
        $(document).ready(function() {
            $('#tabelLaporan').DataTable({
                // Mengubah bahasa bawaan inggris menjadi Bahasa Indonesia
                language: {
                    url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/id.json'
                },
                // Mengatur jumlah data yang tampil
                "pageLength": 5, 
                "lengthMenu": [5, 10, 25, 50],
                // Mematikan sortir otomatis di kolom aksi dan foto
                "columnDefs": [
                    { "orderable": false, "targets": [1, 3, 5] } 
                ]
            });
        });
    </script>
</body>
</html>