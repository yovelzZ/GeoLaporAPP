@extends('layouts.admin')

@section('title', $title ?? 'Data Pengaduan')

@section('content')
<div class="container-fluid p-0">
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">
            <h5 class="fw-bold mb-4">{{ $title ?? 'Data Pengaduan' }}</h5>
            
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>No</th>
                            <th>Foto</th>
                            <th>Detail Laporan</th>
                            <th>Status</th>
                            <th>Aksi</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($laporans as $index => $item)
                        <tr>
                            <td>{{ $index + 1 }}</td>
                            <td>
                                @if($item->foto)
                                    <img src="{{ asset('storage/' . str_replace('public/', '', $item->foto)) }}" width="60" class="rounded shadow-sm">
                                @else
                                    <div class="bg-light rounded text-center" style="width:60px;height:60px;line-height:60px;">
                                        <i class="bi bi-image text-muted"></i>
                                    </div>
                                @endif
                            </td>
                            <td>
                                <h6 class="mb-1 fw-bold">{{ $item->judul }}</h6>
                                <p class="text-muted small mb-1">{{ Str::limit($item->deskripsi, 60) }}</p>
                                <div class="mb-2">
                                    <span class="badge bg-light text-dark"><i class="bi bi-tag-fill"></i> {{ $item->kategori ?? 'Lainnya' }}</span>
                                    <small class="text-muted ms-2"><i class="bi bi-clock"></i> {{ $item->created_at->format('d M Y') }}</small>
                                    <span class="badge bg-danger bg-opacity-10 text-danger px-2 py-1 rounded ms-2">
                                        <i class="bi bi-fire"></i> {{ $item->dukungans_count ?? 0 }} Dukungan
                                    </span>
                                </div>
                                <div class="d-flex flex-column gap-1 mt-2">
                                    <small class="text-muted"><i class="bi bi-geo-alt-fill text-danger"></i> <span class="lokasi-text" data-lat="{{ $item->latitude }}" data-lng="{{ $item->longitude }}">Memuat alamat...</span></small>
                                    <a href="https://www.google.com/maps?q={{ $item->latitude }},{{ $item->longitude }}" target="_blank" class="btn btn-sm btn-outline-danger mt-1" style="width: fit-content; font-size: 11px;">
                                        <i class="bi bi-map"></i> Buka di Google Maps
                                    </a>
                                </div>
                            </td>
                            <td>
                                @if(strtolower($item->status) == 'selesai')
                                    <span class="badge bg-success">Selesai</span>
                                @elseif(strtolower($item->status) == 'diproses')
                                    <span class="badge bg-primary">Diproses</span>
                                @else
                                    <span class="badge bg-warning text-dark">Menunggu</span>
                                @endif
                            </td>
                            <td>
                                <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#modalDetail{{ $item->id }}">Ubah Status</button>
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
                            <td colspan="5" class="text-center text-muted py-4">Belum ada data.</td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const lokasiElements = document.querySelectorAll('.lokasi-text');
        
        lokasiElements.forEach((el, index) => {
            const lat = el.getAttribute('data-lat');
            const lng = el.getAttribute('data-lng');
            
            // Fetch alamat menggunakan API gratis (Nominatim OpenStreetMap)
            // Diberi delay agar tidak terkena limit (1 request per detik per IP untuk nominatim)
            setTimeout(() => {
                fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}`)
                    .then(response => response.json())
                    .then(data => {
                        el.innerText = data.display_name ? data.display_name : "Alamat tidak ditemukan";
                    })
                    .catch(error => {
                        el.innerText = `Lat: ${lat}, Lng: ${lng}`;
                    });
            }, index * 1000); // delay 1 detik tiap baris
        });
    });
</script>
@endpush
