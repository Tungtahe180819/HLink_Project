<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@page import="model.User" %>
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

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
    <link rel="stylesheet" href="css/customer.css">
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

        <div class="voucher-section">
            <label class="voucher-title">Mã giảm giá (Voucher)</label>
            <div class="voucher-input-group">
                <input type="text" id="voucherCodeInput" class="voucher-input" placeholder="Ví dụ: HLINKNEW">
                <button type="button" class="btn-apply-voucher" onclick="applyVoucher()">Áp dụng</button>
            </div>
            <p id="voucherMsg" style="font-size: 12px; margin-top: 5px;"></p>
        </div>
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

    <div id="map" style="height: 400px; margin: 15px 0;"></div>

    <div id="price-box" style="padding: 15px; background: #f8fafc; border-radius: 8px; border: 1px solid #e2e8f0;">
        Thành tiền: <span id="finalPriceElem" style="font-weight: bold; color: #ff5722; font-size: 1.2em;">0</span> VNĐ
    </div>

    <button id="confirm-btn" onclick="confirmOrder()" class="btn-confirm" style="width: 100%; padding: 15px; background: #0A66C2; color: white; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 10px;">
        XÁC NHẬN ĐẶT CHUYẾN
    </button>
</main>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://unpkg.com/leaflet-routing-machine@3.2.12/dist/leaflet-routing-machine.js"></script>
<script>
    // --- 1. KHỞI TẠO BIẾN TOÀN CỤC ---
    const map = L.map('map').setView([21.0125, 105.5255], 15);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
    let pickupMarker, dropoffMarker, pollInterval;
    let currentDistance = 0;
    let finalPriceToSubmit = 0;
    let appliedVoucherCode = "";

    const control = L.Routing.control({
        waypoints: [],
        lineOptions: {styles: [{color: '#0A66C2', weight: 6}]},
        routeWhileDragging: false,
        createMarker: () => null
    }).addTo(map);

    // --- 2. HÀM DÙNG CHUNG ---
    function setPoint(latlng, type, address = "Vị trí đã chọn") {
        const isPickup = type === 'pickup';
        control.spliceWaypoints(isPickup ? 0 : 1, 1, latlng);
        document.getElementById(isPickup ? 'pickup-input' : 'dropoff-input').value = address;

        const marker = L.marker(latlng).addTo(map);
        if (isPickup) { if (pickupMarker) map.removeLayer(pickupMarker); pickupMarker = marker; }
        else { if (dropoffMarker) map.removeLayer(dropoffMarker); dropoffMarker = marker; }
    }

    map.on('contextmenu', (e) => {
        const waypoints = control.getPlan().getWaypoints();
        if (!waypoints[0].latLng) setPoint(e.latlng, 'pickup');
        else setPoint(e.latlng, 'dropoff');
    });

    // --- 3. HÀM TÍNH TIỀN ---
    function calculatePrice() {
        if (currentDistance > 0) {
            const unitPrice = parseFloat(document.getElementById('service-type').value);
            const total = Math.round(currentDistance * unitPrice);

            const priceDisplay = document.getElementById('finalPriceElem');
            priceDisplay.innerText = total.toLocaleString('vi-VN');
            priceDisplay.style.color = "#ff5722";

            finalPriceToSubmit = total;
            appliedVoucherCode = ""; // Reset voucher khi đổi lộ trình
            document.getElementById('voucherMsg').innerText = "";
        }
    }

    control.on('routesfound', (e) => {
        currentDistance = e.routes[0].summary.totalDistance / 1000;
        document.getElementById('distance').value = currentDistance.toFixed(2) + " km";
        calculatePrice();
    });

    // --- 4. HÀM VOUCHER ---
    function applyVoucher() {
        const code = document.getElementById('voucherCodeInput').value.trim();
        const msg = document.getElementById('voucherMsg');
        const priceDisplay = document.getElementById('finalPriceElem');

        // Lấy giá trị gốc (trước khi giảm)
        let originalPrice = Math.round(currentDistance * parseFloat(document.getElementById('service-type').value));

        if (originalPrice === 0) {
            msg.innerText = "⚠️ Vui lòng chọn lộ trình trên bản đồ trước!";
            msg.style.color = "#f59e0b";
            return;
        }

        if (code === "") {
            msg.innerText = "⚠️ Bạn chưa nhập mã giảm giá!";
            msg.style.color = "#f59e0b";
            return;
        }

        fetch('check-voucher?code=' + code)
            .then(res => res.json())
            .then(data => {
                if (data.isValid) {
                    let discount = (originalPrice * data.percent) / 100;
                    if (discount > data.maxDiscount) discount = data.maxDiscount;
                    let finalPrice = originalPrice - discount;

                    // Hiển thị giá gạch ngang khi thành công
                    priceDisplay.innerHTML = `
                        <span class="old-price-strikethrough">\${originalPrice.toLocaleString()}</span>
                        <span class="new-price-highlight">\${finalPrice.toLocaleString()} VNĐ</span>
                    `;

                    finalPriceToSubmit = finalPrice;
                    appliedVoucherCode = code;
                    msg.innerHTML = `✅ Áp dụng thành công! Giảm <b>\${data.percent}%</b>`;
                    msg.style.color = "#166534";
                } else {
                    // --- PHẦN HIỂN THỊ LỖI KHI NHẬP SAI ---
                    msg.innerText = "❌ Mã voucher không tồn tại hoặc đã hết hạn!";
                    msg.style.color = "#ef4444"; // Màu đỏ lỗi

                    // Reset lại hiển thị giá về ban đầu (xóa gạch ngang cũ nếu có)
                    priceDisplay.innerHTML = `<span style="color: #ff5722; font-weight: bold;">\${originalPrice.toLocaleString()} VNĐ</span>`;

                    finalPriceToSubmit = originalPrice;
                    appliedVoucherCode = "";

                    // Thêm hiệu ứng rung nhẹ cho ô nhập liệu để khách biết là sai
                    const input = document.getElementById('voucherCodeInput');
                    input.style.border = "1px solid red";
                    setTimeout(() => { input.style.border = "1px solid #ddd"; }, 2000);
                }
            })
            .catch(err => {
                msg.innerText = "❗ Lỗi hệ thống, vui lòng thử lại sau!";
                msg.style.color = "red";
            });
    }

    // --- 5. XÁC NHẬN ĐẶT CHUYẾN ---
    function confirmOrder() {
        const dist = parseFloat(document.getElementById('distance').value);
        if (isNaN(dist) || dist === 0) return alert("Vui lòng chọn lộ trình!");

        const btn = document.getElementById('confirm-btn');
        btn.disabled = true;
        btn.innerText = "⏳ ĐANG TÌM TÀI XẾ...";

        fetch('book', {
            method: 'POST',
            body: new URLSearchParams({
                'customerId': document.getElementById('customer-id').value,
                'pickup': document.getElementById('pickup-input').value,
                'dropoff': document.getElementById('dropoff-input').value,
                'distance': dist,
                'totalPrice': finalPriceToSubmit,
                'appliedVoucher': appliedVoucherCode,
                'serviceType': document.getElementById('service-type').value
            })
        }).then(res => res.text()).then(data => {
            if (data.includes("success")) {
                alert("Đặt chuyến thành công!");
                // startChecking(data.split(":")[1]);
            } else {
                alert("Lỗi: " + data);
                btn.disabled = false;
                btn.innerText = "XÁC NHẬN ĐẶT CHUYẾN";
            }
        });
    }

    // --- AUTOCOMPLETE (Giữ nguyên logic của Tùng) ---
    const debounce = (fn, ms) => {
        let t;
        return (...a) => {
            clearTimeout(t);
            t = setTimeout(() => fn(...a), ms);
        };
    };

    async function fetchSuggestions(query, listId, inputId, type) {
        if (query.length < 3) return;
        const res = await fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${query}&countrycodes=vn&limit=5`);
        const data = await res.json();
        const list = document.getElementById(listId);
        list.innerHTML = "";
        list.style.display = data.length ? "block" : "none";
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

    document.addEventListener('click', e => {
        if (!e.target.closest('.input-group')) document.querySelectorAll('.suggestions-list').forEach(l => l.style.display = 'none');
    });
</script>
</body>
</html>