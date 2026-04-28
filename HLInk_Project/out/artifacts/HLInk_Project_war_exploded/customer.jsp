<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="model.User"%>
<%
    // 1. Kiểm tra quyền truy cập
    User user = (User) session.getAttribute("account");
    if (user == null || !user.getRole().equalsIgnoreCase("customer")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>H-Link | Đặt Chuyến</title>

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <link rel="stylesheet" href="css/customer.css"> <style>
    /* Thêm hiệu ứng cho trạng thái đang tìm tài xế */
    .finding-driver {
        background: #6c757d !important;
        cursor: not-allowed !important;
    }
    .suggestions-list {
        position: absolute; background: white; width: 100%;
        z-index: 1000; list-style: none; padding: 0; border: 1px solid #ccc; display: none;
    }
    .suggestions-list li { padding: 8px; cursor: pointer; border-bottom: 1px solid #eee; }
    .suggestions-list li:hover { background: #f0f0f0; }
</style>
</head>
<body>
<header class="navbar">
    <div class="logo">H-LINK</div>
    <div class="nav-right">
        <span class="user-info">Xin chào, <b><%= user.getFullName() %></b>!</span>
        <a href="logout" class="logout-btn">Đăng xuất</a>
    </div>
</header>

<main class="booking-container">
    <div class="booking-form">
        <h2>Bạn muốn đi đâu hôm nay?</h2>

        <input type="hidden" id="customer-id" value="<%= user.getUserId() %>">

        <div class="input-group">
            <label>📍 Điểm đón:</label>
            <input type="text" id="pickup-input" placeholder="Nhập địa chỉ hoặc click chuột phải trên bản đồ" autocomplete="off">
            <ul id="pickup-suggestions" class="suggestions-list"></ul>
        </div>

        <div class="input-group">
            <label>🏁 Điểm đến:</label>
            <input type="text" id="dropoff-input" placeholder="Nhập điểm đến..." autocomplete="off">
            <ul id="dropoff-suggestions" class="suggestions-list"></ul>
        </div>

        <div class="row">
            <div class="col">
                <label>Dịch vụ:</label>
                <select id="service-type" onchange="calculatePrice()">
                    <option value="13000">Đi nhờ (13k/km)</option>
                    <option value="10000">Ship đồ (10k/km)</option>
                </select>
            </div>
            <div class="col">
                <label>Quãng đường:</label>
                <input type="text" id="distance" readonly placeholder="0 km">
            </div>
        </div>

        <div id="map"></div>

        <div id="price-box">
            Thành tiền: <span id="amount" style="font-weight: bold; color: #ff5722;">0</span> VNĐ
        </div>

        <button id="confirm-btn" onclick="confirmOrder()" class="btn-confirm">
            XÁC NHẬN ĐẶT CHUYẾN
        </button>
    </div>
</main>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.js"></script>
<script>
    // --- 1. KHỞI TẠO ---
    const map = L.map('map').setView([21.0125, 105.5255], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);

    let pickupMarker, dropoffMarker, pollInterval;

    const control = L.Routing.control({
        waypoints: [],
        lineOptions: { styles: [{ color: '#0A66C2', weight: 6 }] },
        routeWhileDragging: false,
        createMarker: () => null // Ẩn marker mặc định để dùng marker tự định nghĩa bên dưới
    }).addTo(map);

    // --- 2. HÀM DÙNG CHUNG: VẼ MARKER & CẬP NHẬT ĐIỂM ---
    function setPoint(latlng, type, address = "Vị trí đã chọn") {
        const isPickup = type === 'pickup';
        const idx = isPickup ? 0 : 1;
        const iconUrl = isPickup
            ? 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png'
            : 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png';

        // Cập nhật tọa độ cho Routing
        control.spliceWaypoints(idx, 1, latlng);
        document.getElementById(isPickup ? 'pickup-input' : 'dropoff-input').value = address;

        // Vẽ Marker tùy chỉnh
        const marker = L.marker(latlng, {
            icon: new L.Icon({
                iconUrl: iconUrl, shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                iconSize: [25, 41], iconAnchor: [12, 41], popupAnchor: [1, -34], shadowSize: [41, 41]
            })
        }).addTo(map).bindPopup(isPickup ? "Điểm đón" : "Điểm đến").openPopup();

        if (isPickup) { if (pickupMarker) map.removeLayer(pickupMarker); pickupMarker = marker; }
        else { if (dropoffMarker) map.removeLayer(dropoffMarker); dropoffMarker = marker; }
    }

    // Click chuột phải để chọn điểm
    map.on('contextmenu', (e) => {
        const waypoints = control.getPlan().getWaypoints();
        if (!waypoints[0].latLng) setPoint(e.latlng, 'pickup');
        else setPoint(e.latlng, 'dropoff');
    });

    // Tính tiền tự động
    // Biến toàn cục để lưu quãng đường hiện tại
    let currentDistance = 0;

    // --- HÀM TÍNH TIỀN RIÊNG BIỆT ---
    function calculatePrice() {
        if (currentDistance > 0) {
            // Lấy đơn giá từ select
            const unitPrice = parseFloat(document.getElementById('service-type').value);

            // Tính tổng tiền
            const total = Math.round(currentDistance * unitPrice);

            // Hiển thị lên giao diện
            document.getElementById('amount').innerText = total.toLocaleString('vi-VN');
        }
    }

    // Sự kiện khi bản đồ tìm thấy lộ trình (vẽ xong đường)
    control.on('routesfound', (e) => {
        // Cập nhật quãng đường từ bản đồ
        currentDistance = e.routes[0].summary.totalDistance / 1000;

        // Hiển thị quãng đường vào ô input
        document.getElementById('distance').value = currentDistance.toFixed(2) + " km";

        // Gọi hàm tính tiền
        calculatePrice();
    });

    // --- 3. AUTOCOMPLETE (Đã tinh gọn) ---
    const debounce = (fn, ms) => { let t; return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); }; };

    async function fetchSuggestions(query, listId, inputId, type) {
        if (query.length < 3) return;
        const res = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${query}&countrycodes=vn&limit=5`);
        const data = await res.json();
        const list = document.getElementById(listId);
        list.innerHTML = ""; list.style.display = data.length ? "block" : "none";

        data.forEach(item => {
            const li = document.createElement("li");
            li.textContent = item.display_name;
            li.onclick = () => {
                setPoint(L.latLng(item.lat, item.lon), type, item.display_name);
                map.panTo([item.lat, item.lon]);
                list.style.display = "none";
            };
            list.appendChild(li);
        });
    }

    document.getElementById('pickup-input').addEventListener('input', debounce(e => fetchSuggestions(e.target.value, 'pickup-suggestions', 'pickup-input', 'pickup'), 500));
    document.getElementById('dropoff-input').addEventListener('input', debounce(e => fetchSuggestions(e.target.value, 'dropoff-suggestions', 'dropoff-input', 'dropoff'), 500));

    // --- 4. ĐẶT ĐƠN & THEO DÕI ---
    function confirmOrder() {
        const dist = parseFloat(document.getElementById('distance').value);
        if (dist === 0) return alert("Vui lòng chọn lộ trình!");

        const btn = document.getElementById('confirm-btn');
        btn.disabled = true; btn.innerText = "⏳ ĐANG TÌM TÀI XẾ...";

        fetch('book', {
            method: 'POST',
            body: new URLSearchParams({
                'customerId': document.getElementById('customer-id').value,
                'pickup': document.getElementById('pickup-input').value,
                'dropoff': document.getElementById('dropoff-input').value,
                'distance': dist,
                'amount': Math.round(dist * parseFloat(document.getElementById('service-type').value))
            })
        }).then(res => res.text()).then(data => {
            if (data.startsWith("success")) startChecking(data.split(":")[1]);
        });
    }

    function startChecking(id) {
        pollInterval = setInterval(() => {
            fetch('check-booking-status?bookingId=' + id).then(res => res.json()).then(data => {
                if (data.status === "confirmed") {
                    clearInterval(pollInterval);
                    alert(`🔔 Tài xế ${data.driverName} đã nhận chuyến!`);
                    const btn = document.getElementById('confirm-btn');
                    btn.innerText = "TÀI XẾ ĐANG ĐẾN"; btn.style.background = "#28a745";
                }
            });
        }, 4000);
    }

    document.addEventListener('click', e => { if (!e.target.closest('.input-group')) document.querySelectorAll('.suggestions-list').forEach(l => l.style.display = 'none'); });
</script>
</body>
</html>