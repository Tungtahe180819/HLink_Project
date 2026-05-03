<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khôi phục mật khẩu | H-Link</title>

    <link rel="stylesheet" href="css/forgot-password.css">
</head>
<body>
<div class="forgot-box">
    <h2>Quên mật khẩu?</h2>
    <p>Nhập thông tin cá nhân để khôi phục tài khoản</p>

    <%-- Hiển thị lỗi nếu có --%>
    <% if (request.getAttribute("error") != null) { %>
    <div class="msg-error">
        <strong>Lỗi:</strong> <%= request.getAttribute("error") %>
    </div>
    <% } %>

    <form action="forgot-password" method="POST">
        <div class="input-group">
            <label for="studentId">Mã số sinh viên (studentId)</label>
            <input type="text" id="studentId" name="studentId" required placeholder="Ví dụ: HE170000">
        </div>

        <div class="input-group">
            <label for="phoneNumber">Số điện thoại (phoneNumber)</label>
            <input type="text" id="phoneNumber" name="phoneNumber" required placeholder="Nhập số điện thoại đã đăng ký">
        </div>

        <div class="input-group">
            <label for="newPassword">Mật khẩu mới</label>
            <input type="password" id="newPassword" name="newPassword" required placeholder="Tối thiểu 6 ký tự">
        </div>

        <button type="submit" class="btn-reset">ĐẶT LẠI MẬT KHẨU</button>
    </form>

    <div class="back-link">
        <a href="login.jsp">← Quay lại trang đăng nhập</a>
    </div>
</div>
</body>
</html>