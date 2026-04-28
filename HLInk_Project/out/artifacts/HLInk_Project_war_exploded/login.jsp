<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>H-Link | Đăng nhập hệ thống</title>
    <link rel="stylesheet" href="css/login.css">
    <style>
        /* Thêm hiệu ứng cho thông báo lỗi và thành công */
        .error-msg, .success-msg {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
            font-weight: 600;
            text-align: center;
        }
        .error-msg {
            background-color: #ffeef0;
            color: #d73a49;
            border: 1px solid #ffcfd3;
        }
        .success-msg {
            background-color: #dcffe4;
            color: #1a7f37;
            border: 1px solid #bef5cb;
        }
    </style>
</head>
<body>

<div class="login-box">
    <div class="logo-wrapper">
        <img src="img/logo.png" alt="H-LINK Logo" style="height: 120px; margin-bottom: 15px;">
    </div>

    <h2>H-LINK</h2>
    <p class="subtitle">Kết nối sinh viên Hòa Lạc</p>

    <%-- CẬP NHẬT LOGIC: Nhận thông báo lỗi từ request.getAttribute("errorMessage") --%>
    <%
        String error = (String) request.getAttribute("errorMessage");
        if (error != null) {
    %>
    <div class="error-msg">
        ⚠ <%= error %>
    </div>
    <% } %>

    <%-- Thông báo đăng ký thành công --%>
    <% if ("success".equals(request.getParameter("msg"))) { %>
    <div class="success-msg">
        ✅ Đăng ký thành công! Mời bạn đăng nhập.
    </div>
    <% } %>

    <%-- Form đăng nhập --%>
    <form action="login" method="post">
        <div class="form-group">
            <label>Số điện thoại:</label>
            <%-- GIỮ NGUYÊN NAME="phone" khớp với Servlet --%>
            <input type="tel" name="phone" placeholder="09xxxxxxxx" required autofocus
                   value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>">
        </div>

        <div class="form-group">
            <label>Mật khẩu:</label>
            <%-- GIỮ NGUYÊN NAME="pass" khớp với Servlet --%>
            <input type="password" name="pass" placeholder="••••••••" required>
        </div>

        <button type="submit" class="btn-login">ĐĂNG NHẬP</button>
    </form>

    <p class="footer-link">
        Chưa có tài khoản? <a href="register.jsp">Đăng ký ngay</a>
    </p>
</div>

<%-- Script tự động ẩn thông báo sau 4 giây --%>
<%-- Script xử lý hiện popup báo lỗi --%>
<script>
    window.onload = function() {
        // Kiểm tra xem Server có gửi tín hiệu lỗi về không
        <% if ("true".equals(request.getAttribute("loginError"))) { %>
        const passwordInput = document.getElementsByName("pass")[0];

        // 1. Thiết lập nội dung lỗi cho popup trình duyệt
        passwordInput.setCustomValidity("Số điện thoại hoặc mật khẩu không chính xác!");

        // 2. Ép trình duyệt hiển thị popup báo lỗi ngay lập tức
        passwordInput.reportValidity();

        // 3. Xóa thông báo lỗi khi người dùng bắt đầu gõ lại (để họ có thể bấm Đăng nhập tiếp)
        passwordInput.oninput = function() {
            passwordInput.setCustomValidity("");
        };
        <% } %>
    };
</script>

</body>
</html>