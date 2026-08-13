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
    
    @stack('css')

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #F8F9FA;
            color: #333;
            overflow-x: hidden;
        }

        /* Sidebar Styling */
        #sidebar {
            min-width: 250px;
            max-width: 250px;
            background-color: #2A3F54;
            color: #fff;
            min-height: 100vh;
            transition: all 0.3s;
        }

        #sidebar .sidebar-header {
            padding: 20px;
            background: #172D44;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        #sidebar .sidebar-header img {
            width: 40px;
            background: white;
            padding: 5px;
            border-radius: 5px;
        }

        #sidebar ul.components {
            padding: 20px 0;
        }

        #sidebar ul li {
            padding: 10px 20px;
        }

        #sidebar ul li a {
            color: #fff;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 15px;
            font-size: 14px;
        }

        #sidebar ul li:hover, #sidebar ul li.active {
            background: #172D44;
            border-left: 4px solid #3b7ddd;
        }

        .category-title {
            font-size: 11px;
            text-transform: uppercase;
            color: #8da2ba;
            font-weight: bold;
            letter-spacing: 1px;
            padding: 10px 20px;
            margin-top: 10px;
        }

        /* Topbar & Content */
        #content {
            width: 100%;
            padding: 20px;
        }

        .topbar {
            background: #fff;
            padding: 15px 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            border-radius: 8px;
        }

        .topbar h4 {
            margin: 0;
            font-size: 18px;
            font-weight: 600;
        }

    </style>
</head>
<body class="d-flex">

    <!-- SIDEBAR -->
    <nav id="sidebar">
        <div class="sidebar-header">
            <i class="bi bi-map-fill fs-3 text-warning"></i>
            <div>
                <h6 class="mb-0 fw-bold">GeoLapor</h6>
                <small>ADMIN DASHBOARD</small>
            </div>
        </div>

        <ul class="list-unstyled components">
            <li class="category-title">DASHBOARD</li>
            <li class="{{ request()->is('/') || request()->is('admin/dashboard') ? 'active' : '' }}">
                <a href="{{ url('/') }}"><i class="bi bi-house-door-fill"></i> BERANDA</a>
            </li>

            <li class="category-title">PENGADUAN</li>
            <li class="{{ request()->is('laporan') ? 'active' : '' }}">
                <a href="{{ url('/laporan') }}"><i class="bi bi-file-earmark-text"></i> DATA PENGADUAN</a>
            </li>
            <li class="{{ request()->is('laporan/menunggu') ? 'active' : '' }}">
                <a href="{{ url('/laporan/menunggu') }}"><i class="bi bi-hourglass-split"></i> BELUM DITINDAKLANJUTI</a>
            </li>
            <li class="{{ request()->is('laporan/proses') ? 'active' : '' }}">
                <a href="{{ url('/laporan/proses') }}"><i class="bi bi-gear"></i> DALAM PROSES</a>
            </li>
            <li class="{{ request()->is('laporan/selesai') ? 'active' : '' }}">
                <a href="{{ url('/laporan/selesai') }}"><i class="bi bi-check-circle"></i> SELESAI</a>
            </li>

            <li class="category-title">PETA</li>
            <li class="{{ request()->is('peta') ? 'active' : '' }}">
                <a href="{{ url('/peta') }}"><i class="bi bi-map"></i> PETA INFRASTRUKTUR</a>
            </li>

            <li class="category-title">AKUN</li>
            <li>
                <a href="#"><i class="bi bi-box-arrow-left"></i> LOGOUT</a>
            </li>
        </ul>
    </nav>

    <!-- KONTEN UTAMA -->
    <div id="content">
        <div class="topbar">
            <h4>@yield('title', 'Dashboard Admin')</h4>
            <div>
                <span class="text-muted"><i class="bi bi-person-circle"></i> Administrator</span>
            </div>
        </div>

        @yield('content')
    </div>

    <!-- SCRIPT LIBRARY -->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    @stack('scripts')
</body>
</html>
