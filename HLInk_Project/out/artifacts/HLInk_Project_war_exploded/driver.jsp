<%@page import="model.Booking"%>
<%@page import="java.util.List"%>
<%@page import="dao.UserDAO"%>
<%@page import="model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. Kiểm tra quyền truy cập
    User user = (User) session.getAttribute("account");
    if (user == null || !user.getRole().equalsIgnoreCase("driver")) {
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO dao = new UserDAO();
    // 2. Lấy danh sách chuyến (Tùy biến theo DAO của bạn)
    // List này nên bao gồm cả chuyến 'pending' và chuyến tài xế này đang nhận 'confirmed'
    List<Booking> bookingList = dao.getAvailableAndMyBookings(user.getUserId());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>H-Link Driver | Quản lý chuyến xe</title>
    <link rel="stylesheet" href="css/driver.css">
    <style>
        /* Bổ sung một số style nhanh cho các trạng thái */
        .status-badge {
            padding: 4px 10px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .status-pending { background: #fff3cd; color: #856404; }
        .status-confirmed { background: #d1ecf1; color: #0c5460; }

        .btn-complete {
            background-color: #28a745 !important; /* Màu xanh lá cho nút hoàn thành */
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
        }
        .btn-complete:hover { background-color: #218838 !important; }
    </style>
</head>
<body>

<header class="header-driver">
    <div class="logo">H-LINK DRIVER</div>
    <div>
        <span>Tài xế: <b><%= user.getFullName() %></b></span>
        <a href="logout" style="color: #fff; margin-left: 15px; text-decoration: underline;">Đăng xuất</a>
    </div>
</header>

<main class="driver-container">
    <h2>Lộ trình trực tuyến</h2>
    <p>Nhận chuyến mới hoặc quản lý chuyến xe đang thực hiện.</p>

    <div id="booking-list">
        <%
            if (bookingList == null || bookingList.isEmpty()) {
        %>
        <div class="no-booking">
            <h3>📭 Hiện tại không có chuyến xe nào.</h3>
            <button class="btn-refresh" onclick="location.reload()">Làm mới</button>
        </div>
        <%
        } else {
            for (Booking b : bookingList) {
        %>
        <div class="booking-card" style="<%= "confirmed".equals(b.getStatus()) ? "border-left-color: #28a745;" : "" %>">
            <div class="info-group">
                <p>
                        <span class="status-badge <%= "pending".equals(b.getStatus()) ? "status-pending" : "status-confirmed" %>">
                            <%= b.getStatus().equals("pending") ? "Chờ tài xế" : "Đang thực hiện" %>
                        </span>
                </p>
                <p>📍 <b>Từ:</b> <%= b.getPickupLocation() %></p>
                <p>🏁 <b>Đến:</b> <%= b.getDropoffLocation() %></p>
                <p>📏 <b>Cách bạn:</b> <%= b.getDistanceKm() %> km</p>
                <p>💰 <b>Thu nhập:</b> <span class="price-highlight"><%= String.format("%,.0f", b.getTotalPrice()) %> VNĐ</span></p>
            </div>

            <div class="actions">
                <% if ("pending".equals(b.getStatus())) { %>
                <button class="btn-accept" onclick="updateStatus(<%= b.getBookingId() %>, 'confirmed')">
                    NHẬN CHUYẾN
                </button>
                <% } else if ("confirmed".equals(b.getStatus()) && b.getDriverId() == user.getUserId()) { %>
                <button class="btn-complete" onclick="updateStatus(<%= b.getBookingId() %>, 'completed')">
                    HOÀN THÀNH
                </button>
                <% } %>
            </div>
        </div>
        <%
                }
            }
        %>
    </div>
</main>

<script>
    function updateStatus(bookingId, status) {
        let confirmMsg = (status === 'confirmed') ? "Bạn chắc chắn muốn nhận chuyến này?" : "Xác nhận đã hoàn thành chuyến xe?";

        if (confirm(confirmMsg)) {
            // Gửi dữ liệu về UpdateBookingServlet
            fetch('update-booking', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({
                    'bookingId': bookingId,
                    'status': status
                })
            })
                .then(res => res.text())
                .then(data => {
                    if (data.trim() === "success") {
                        alert(status === 'confirmed' ? "✅ Nhận chuyến thành công!" : "✅ Chuyến đi đã hoàn thành!");
                        location.reload();
                    } else {
                        alert("❌ Lỗi: " + data);
                        location.reload();
                    }
                })
                .catch(err => alert("❌ Lỗi kết nối server!"));
        }
    }

    // Tự động làm mới danh sách mỗi 30 giây để cập nhật chuyến mới
    setInterval(() => {
        // location.reload(); // Hoặc viết hàm fetch để update list mà không load lại trang
    }, 30000);
</script>

</body>
</html>