<%@page import="model.Booking" %>
<%@page import="java.util.List" %>
<%@page import="dao.UserDAO" %>
<%@page import="model.User" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%
    User user = (User) session.getAttribute("account");
    if (user == null || !user.getRole().equalsIgnoreCase("admin")) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<Booking> allList = (List<Booking>) request.getAttribute("allList");
    List<User> userList = (List<User>) request.getAttribute("userList");

    if (allList == null || userList == null) {
        response.sendRedirect("admin-manager");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>H-Link Admin | Quản trị hệ thống</title>
    <link rel="stylesheet" href="css/admin.css">
</head>
<body>

<div class="sidebar">
    <h2>H-LINK</h2>
    <p class="admin-info">Quản trị viên: <b><%= user.getFullName() %>
    </b></p>
    <ul class="sidebar-menu">
        <li class="tab-link active" onclick="openTab(event, 'dashboard-tab')">📊 Dashboard</li>
        <li class="tab-link" onclick="openTab(event, 'users-tab')">👥 Người dùng</li>
        <li class="tab-link" onclick="openTab(event, 'bookings-tab')">🚗 Chuyến đi</li>
    </ul>
    <div class="logout-box">
        <a href="logout" style="color: #ef4444; text-decoration: none; font-weight: bold; font-size: 14px;">🚪 Đăng
            xuất</a>
    </div>
</div>

<div class="main-content">

    <div id="dashboard-tab" class="tab-content active">
        <h1>Bảng điều khiển</h1>

        <%
            // Khởi tạo các biến thống kê
            int pending = 0;
            int confirmed = 0;
            int completed = 0;
            double totalRevenue = 0;
            double completedRevenue = 0;

            for (Booking b : allList) {
                totalRevenue += b.getTotalPrice();
                if ("pending".equalsIgnoreCase(b.getStatus())) {
                    pending++;
                } else if ("confirmed".equalsIgnoreCase(b.getStatus())) {
                    confirmed++;
                } else if ("completed".equalsIgnoreCase(b.getStatus())) {
                    completed++;
                    completedRevenue += b.getTotalPrice(); // Chỉ tính doanh thu thực tế từ chuyến đã xong
                }
            }
        %>

        <div class="card-stats">
            <div class="stat-box">
                <h3>Tổng số chuyến</h3>
                <p><%= allList.size() %>
                </p>
            </div>
            <div class="stat-box">
                <h3>Đã hoàn thành</h3>
                <p style="color: #0369a1;"><%= completed %>
                </p>
            </div>
            <div class="stat-box">
                <h3>Doanh thu thực tế</h3>
                <p style="color: #166534;"><%= String.format("%,.0f", completedRevenue) %> đ</p>
            </div>
        </div>

        <div class="dashboard-details"
             style="margin-top: 30px; display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
            <div class="stat-table-box"
                 style="background: white; padding: 24px; border-radius: 16px; border: 1px solid #e2e8f0;">
                <h3 style="margin-bottom: 20px; font-size: 16px;">📈 Chi tiết trạng thái</h3>
                <table style="width: 100%; border-collapse: collapse;">
                    <tr style="border-bottom: 1px solid #f1f5f9;">
                        <td style="padding: 12px 0;">🕒 Đang chờ (Pending)</td>
                        <td style="text-align: right; font-weight: 700; color: #f59e0b;"><%= pending %>
                        </td>
                    </tr>
                    <tr style="border-bottom: 1px solid #f1f5f9;">
                        <td style="padding: 12px 0;">✅ Đã xác nhận (Confirmed)</td>
                        <td style="text-align: right; font-weight: 700; color: #22c55e;"><%= confirmed %>
                        </td>
                    </tr>
                    <tr style="border-bottom: 1px solid #f1f5f9;">
                        <td style="padding: 12px 0;">🎉 Đã hoàn thành (Completed)</td>
                        <td style="text-align: right; font-weight: 700; color: #0369a1;"><%= completed %>
                        </td>
                    </tr>
                </table>
            </div>

            <div class="stat-table-box"
                 style="background: white; padding: 24px; border-radius: 16px; border: 1px solid #e2e8f0;">
                <h3 style="margin-bottom: 20px; font-size: 16px;">💰 Hiệu suất doanh thu</h3>
                <div style="margin-top: 10px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 8px;">
                        <p style="font-size: 13px; color: #64748b; margin: 0;">Doanh thu thực tế / Tổng dự kiến</p>
                        <p style="font-size: 13px; font-weight: 600; color: #1e293b; margin: 0;">
                            <span style="color: #166534;"><%= String.format("%,.0f", completedRevenue) %>đ</span>
                            /
                            <span style="color: #64748b;"><%= String.format("%,.0f", totalRevenue) %>đ</span>
                        </p>
                    </div>

                    <div style="height: 12px; background: #f1f5f9; border-radius: 6px; margin-bottom: 10px; overflow: hidden; display: flex;">
                        <%
                            double percent = (totalRevenue > 0) ? (completedRevenue / totalRevenue) * 100 : 0;
                        %>
                        <div style="width: <%= percent %>%; height: 100%; background: #0A66C2; border-radius: 6px; transition: width 0.5s ease;"></div>
                    </div>

                    <div style="display: flex; align-items: center; gap: 8px;">
                        <p style="font-weight: 700; font-size: 24px; margin: 0; color: #1e293b;"><%= String.format("%.1f", percent) %>
                            %</p>
                        <span style="font-size: 12px; color: #10b981; background: #f0fdf4; padding: 2px 8px; border-radius: 12px; font-weight: 600;">
                + Tỉ lệ hoàn thành
            </span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="users-tab" class="tab-content">
        <h1>Quản lý người dùng</h1>
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Họ và Tên</th>
                    <th>Số điện thoại</th>
                    <th>MSSV</th>
                    <th>Vai trò</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <% for (User u : userList) { %>
                <tr>
                    <td style="font-weight: bold;">#<%= u.getUserId() %>
                    </td>
                    <td><%= u.getFullName() %>
                    </td>
                    <td><%= u.getPhoneNumber() %>
                    </td>
                    <td><%= u.getStudentId() %>
                    </td>
                    <td>
                        <%
                            // Kiểm tra an toàn: nếu role null thì gán mặc định là "customer"
                            String currentRole = (u.getRole() != null) ? u.getRole() : "customer";
                        %>
                        <span class="status <%= currentRole.equalsIgnoreCase("admin") ? "status-confirmed" : "status-pending" %>">
                        <%= currentRole.toUpperCase() %>
                        </span>
                    </td>
                    <td>
                        <button class="btn-edit"
                                onclick="openEditUserModal(
                                        '<%= u.getUserId() %>',
                                        '<%= u.getFullName() %>',
                                        '<%= u.getPhoneNumber() %>',
                                        '<%= u.getRole() %>',
                                        '<%= (u.getStudentId() != null) ? u.getStudentId().trim() : "" %>')">
                            Sửa
                        </button>

                        <% if (u.getRole().equalsIgnoreCase("admin")) { %>
                        <button class="btn-delete" style="color: #cbd5e1; border-color: #e2e8f0; cursor: not-allowed;"
                                title="Không thể xóa Admin">Xóa
                        </button>
                        <% } else { %>
                        <button class="btn-delete" onclick="deleteUser(<%= u.getUserId() %>)">Xóa</button>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <div id="bookings-tab" class="tab-content">
        <h1>Quản lý chuyến đi</h1>
        <div class="table-container">
            <table>
                <thead>
                <tr>
                    <th>Mã đơn</th>
                    <th>Khách hàng</th>
                    <th>Tài xế</th>
                    <th>Lộ trình</th>
                    <th>Giá tiền</th>
                    <th>Trạng thái</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <% for (Booking b : allList) { %>
                <tr>
                    <td style="font-weight: bold;">#<%= b.getBookingId() %>
                    </td>
                    <td>ID: <%= b.getCustomerId() %>
                    </td>
                    <td><%= (b.getDriverId() == null || b.getDriverId() == 0) ? "<span style='color: #94a3b8;'>Chưa nhận</span>" : "ID: " + b.getDriverId() %>
                    </td>
                    <td>
                        <div style="font-size: 13px;"><span
                                style="color: #64748b;">S:</span> <%= b.getPickupLocation() %><br><span
                                style="color: #64748b;">E:</span> <%= b.getDropoffLocation() %>
                        </div>
                    </td>
                    <td style="font-weight: 600;"><%= String.format("%,.0f", b.getTotalPrice()) %>
                    </td>
                    <td>
                        <span class="status <%= b.getStatus().equalsIgnoreCase("completed") ? "status-completed" :
                                          b.getStatus().equalsIgnoreCase("confirmed") ? "status-confirmed" : "status-pending" %>">
                                          <%= b.getStatus().toUpperCase() %>
                        </span>
                    </td>
                    <td>
                        <button class="btn-delete" onclick="deleteBooking(<%= b.getBookingId() %>)">Xóa</button>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div id="editUserModal" class="modal">
    <div class="modal-content">
        <h2>Chỉnh sửa người dùng</h2>
        <form action="edit-user" method="POST">
            <input type="hidden" name="userId" id="edit-user-id">

            <div class="form-group">
                <label>Họ và tên</label>
                <input type="text" name="fullName" id="edit-full-name" required>
            </div>

            <div class="form-group">
                <label>Số điện thoại</label>
                <input type="text" name="phone" id="edit-phone" required>
            </div>

            <div class="form-group">
                <label>Mã số sinh viên (MSSV)</label>
                <input type="text" name="studentId" id="edit-student-id" required>
            </div>

            <div class="form-group">
                <label>Mật khẩu mới (Để trống nếu giữ nguyên)</label>
                <input type="password" name="password" id="edit-password" placeholder="Nhập pass mới để đổi">
            </div>

            <div class="form-group">
                <label>Vai trò hệ thống</label>
                <select name="role" id="edit-role" required>
                    <option value="" disabled selected>-- Chọn vai trò --</option>
                    <option value="customer">CUSTOMER</option>
                    <option value="driver">DRIVER</option>
                    <option value="admin">ADMIN</option>
                </select>
            </div>

            <div style="display: flex; gap: 10px; margin-top: 20px;">
                <button type="submit" class="btn-save">Xác nhận lưu</button>
                <button type="button" class="btn-cancel" onclick="closeEditModal()">Hủy bỏ</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openTab(evt, tabId) {
        const contents = document.querySelectorAll(".tab-content");
        contents.forEach(c => c.classList.remove("active"));
        const links = document.querySelectorAll(".tab-link");
        links.forEach(l => l.classList.remove("active"));
        document.getElementById(tabId).classList.add("active");
        evt.currentTarget.classList.add("active");
    }

    function openEditUserModal(id, name, phone, role, studentId) {
        console.log("Dữ liệu MSSV nhận được:", studentId);

        document.getElementById('edit-user-id').value = id;
        document.getElementById('edit-full-name').value = name;
        document.getElementById('edit-phone').value = phone;

        // Gán MSSV: Xử lý chuỗi 'null' hoặc 'undefined' do JSP truyền sang nếu có
        if (studentId === 'null' || studentId === 'undefined') {
            document.getElementById('edit-student-id').value = "";
        } else {
            document.getElementById('edit-student-id').value = studentId;
        }

        // Xử lý Role (phải khớp chữ thường)
        const roleSelect = document.getElementById('edit-role');
        if (role) {
            roleSelect.value = role.toLowerCase();
        }

        document.getElementById('edit-password').value = "";
        document.getElementById('editUserModal').style.display = 'block';
    }

    function closeEditModal() {
        document.getElementById('editUserModal').style.display = 'none';
    }

    window.onclick = function (event) {
        var modal = document.getElementById('editUserModal');
        if (event.target == modal) {
            closeEditModal();
        }
    }

    function deleteBooking(id) {
        if (confirm('Bạn có chắc chắn muốn xóa đơn hàng này?')) {
            fetch('delete-booking?id=' + id, {method: 'POST'})
                .then(res => res.text())
                .then(data => {
                    if (data.trim() === "success") location.reload();
                    else alert('❌ Lỗi khi xóa chuyến đi!');
                });
        }
    }

    function deleteUser(id) {
        if (confirm('Bạn có chắc chắn muốn xóa tài khoản này?')) {
            fetch('delete-user?id=' + id, {method: 'POST'})
                .then(res => res.text())
                .then(data => {
                    if (data.trim() === "success") location.reload();
                    else alert('❌ Lỗi: Có thể người dùng đang có chuyến đi dang dở.');
                });
        }
    }
</script>
</body>
</html>