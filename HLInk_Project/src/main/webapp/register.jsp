<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Tham gia H-Link</title>
  <link rel="stylesheet" href="css/register.css">
</head>
<body>

<div class="reg-container">
  <h2>H-LINK</h2>
  <p class="subtitle">Đăng ký để bắt đầu chuyến đi của bạn</p>

  <%-- Logic báo lỗi trùng SĐT --%>
  <% if("exist".equals(request.getParameter("error"))) { %>
  <p class="error">Số điện thoại này đã được sử dụng!</p>
  <% } %>

  <form action="register" method="post" class="register-form">
    <h2>Đăng ký thành viên H-Link</h2>

    <div class="input-group">
      <input type="text" name="fullName" placeholder="Họ và tên" required>
    </div>

    <div class="input-group">
      <input type="text" name="phone" placeholder="Số điện thoại (Dùng để đăng nhập)" required>
    </div>

    <div class="input-group">
      <input type="text" name="studentId" placeholder="Mã số sinh viên (Ví dụ: HE180000)" required>
    </div>

    <div class="input-group">
      <input type="password" name="password" placeholder="Mật khẩu" required>
    </div>

    <div class="role-selector">
      <p class="selector-title">Bạn tham gia với vai trò:</p>

      <div class="role-options">
        <label class="role-option">
          <input type="radio" name="role" value="customer" checked>
          <div class="role-text">
            <span class="role-name">👤 KHÁCH HÀNG (ĐẶT XE & GỬI ĐỒ)</span>
          </div>
        </label>

        <label class="role-option">
          <input type="radio" name="role" value="driver">
          <div class="role-text">
            <span class="role-name">🏍️ TÀI XẾ (CHỞ KHÁCH & SHIP ĐỒ)</span>
          </div>
        </label>
      </div>
    </div>

    <button type="submit" class="btn-register">Hoàn tất đăng ký</button>
  </form>

  <div class="footer-text">
    Đã có tài khoản? <a href="login.jsp">Đăng nhập</a>
  </div>
</div>

</body>
</html>