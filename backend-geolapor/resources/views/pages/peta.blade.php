@extends('layouts.admin')

@section('title', 'Peta Infrastruktur')

@push('css')
    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/leaflet.locatecontrol@0.79.0/dist/L.Control.Locate.min.css" />
    <style>
        #map-full {
            height: 70vh;
            border-radius: 12px;
            z-index: 1;
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
    <div class="card border-0 shadow-sm rounded-4">
        <div class="card-body p-4">
            <h5 class="fw-bold mb-4">Peta Persebaran Seluruh Laporan</h5>
            <div id="map-full"></div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/leaflet.locatecontrol@0.79.0/dist/L.Control.Locate.min.js"></script>
<script src="https://unpkg.com/leaflet.heat@0.2.0/dist/leaflet-heat.js"></script>
<script>
    const map = L.map('map-full').setView([5.1802, 97.1507], 13);
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

    const laporans = @json($laporans);
    laporans.forEach(item => {
        if (item.latitude && item.longitude) {
            let statusColor = item.status === 'Selesai' ? 'green' : (item.status === 'Diproses' ? 'blue' : 'orange');
            let marker = L.marker([item.latitude, item.longitude]).addTo(map);
            
            let popupContent = `
                <div style="min-width: 220px;">
                    <b style="font-size:14px; color:#333;">${item.kategori || 'Lainnya'}</b><br>
                    <span style="font-size:13px; color:#555;">${item.judul}</span><br>
                    Status: <b style="color:${statusColor}">${item.status}</b><br>
                    <hr style="margin:8px 0; border:0; border-top:1px solid #eee;">
                    <span id="alamat-full-${item.id}" style="font-size:12px; color:#777;"><i>📍 Memuat alamat...</i></span><br>
                    <a href="https://www.google.com/maps?q=${item.latitude},${item.longitude}" target="_blank" 
                       style="display:inline-block; margin-top:10px; padding:6px 12px; background:#e74c3c; color:white; text-decoration:none; border-radius:6px; font-size:12px; font-weight:bold; width:100%; text-align:center;">
                       🗺️ Buka di Google Maps
                    </a>
                </div>
            `;
            
            marker.bindPopup(popupContent);
            
            marker.on('popupopen', function() {
                const alamatSpan = document.getElementById(`alamat-full-${item.id}`);
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
        .map(item => [item.latitude, item.longitude, 1.0]);

    if (heatPoints.length > 0) {
        L.heatLayer(heatPoints, {
            radius: 25,
            blur: 15,
            maxZoom: 17,
            max: 5.0,
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

</script>
@endpush
