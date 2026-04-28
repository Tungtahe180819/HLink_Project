package dao;

import model.User;
import model.Booking;
import util.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class UserDAO extends DBContext {

    // 1. Đăng nhập
    public User login(String phone, String pass) {
        String sql = "SELECT * FROM Users WHERE phone_number = ? AND password = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, phone);
            ps.setString(2, pass);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setRole(rs.getString("role"));
                // ... set các trường khác
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace(); // Nó sẽ in lỗi ra tab Output của phần mềm code
        }
        return null;
    }

    // 2. Khách hàng đặt chuyến (Booking)
    public boolean createBooking(int customerId, int serviceId, String pickup, String dropoff, float distance, double total) {
        // Bây giờ biến serviceId đã tồn tại nhờ khai báo ở trên ^
        String sql = "INSERT INTO Bookings (customer_id, service_id, pickup_location, dropoff_location, distance_km, total_price, status) VALUES (?, ?, ?, ?, ?, ?, 'pending')";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, customerId);
            st.setInt(2, serviceId); // Truyền tham số thứ 2 là serviceId
            st.setString(3, pickup);
            st.setString(4, dropoff);
            st.setFloat(5, distance);
            st.setDouble(6, total);

            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi Create Booking: " + e.getMessage());
        }
        return false;
    }

    // 3. Lấy danh sách các chuyến đang chờ (Dành cho Driver)
    public List<Booking> getPendingBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM Bookings WHERE status = 'pending' ORDER BY created_at DESC";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getInt("booking_id"));
                b.setCustomerId(rs.getInt("customer_id"));
                b.setServiceId(rs.getInt("service_id"));
                b.setPickupLocation(rs.getString("pickup_location"));
                b.setDropoffLocation(rs.getString("dropoff_location"));
                b.setDistanceKm(rs.getFloat("distance_km"));
                b.setTotalPrice(rs.getDouble("total_price"));
                b.setStatus(rs.getString("status"));
                b.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(b);
            }
        } catch (Exception e) {
            System.out.println("Lỗi lấy danh sách đơn: " + e.getMessage());
        }
        return list;
    }

    // 4. Tài xế nhận chuyến
    public boolean acceptBooking(int bookingId, int driverId) {
        String sql = "UPDATE Bookings SET driver_id = ?, status = 'confirmed' WHERE booking_id = ? AND status = 'pending'";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, driverId);
            st.setInt(2, bookingId);
            return st.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Lỗi nhận đơn: " + e.getMessage());
        }
        return false;
    }

    // Lấy TẤT CẢ chuyến đi để Admin quản lý
    public List<Booking> getAllBookings() {
        List<Booking> list = new ArrayList<>();
        String sql = "SELECT * FROM Bookings ORDER BY created_at DESC";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            ResultSet rs = st.executeQuery();
            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getInt("booking_id"));
                b.setCustomerId(rs.getInt("customer_id"));
                b.setDriverId(rs.getInt("driver_id") == 0 ? null : rs.getInt("driver_id"));
                b.setPickupLocation(rs.getString("pickup_location"));
                b.setDropoffLocation(rs.getString("dropoff_location"));
                b.setDistanceKm(rs.getFloat("distance_km"));
                b.setTotalPrice(rs.getDouble("total_price"));
                b.setStatus(rs.getString("status"));
                b.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(b);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // Hàm xóa đơn hàng (Nếu Admin muốn dọn dẹp data lỗi)
    public boolean deleteBooking(int id) {
        String sql = "DELETE FROM Bookings WHERE booking_id = ?";
        try {
            PreparedStatement st = connection.prepareStatement(sql);
            st.setInt(1, id);
            return st.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }

    public boolean register(String fullName, String phone, String password, String studentId) {
        // 1. Kiểm tra xem số điện thoại đã tồn tại chưa
        String checkSql = "SELECT user_id FROM Users WHERE phone_number = ?";
        String insertUserSql = "INSERT INTO Users (full_name, phone_number, password, role, student_id, status) VALUES (?, ?, ?, 'customer', ?, 'active')";
        String insertWalletSql = "INSERT INTO Wallets (user_id, balance) VALUES (LAST_INSERT_ID(), 0)";

        try {
            // Tắt auto commit để thực hiện transaction (đảm bảo tạo user xong là phải có ví)
            connection.setAutoCommit(false);

            PreparedStatement stCheck = connection.prepareStatement(checkSql);
            stCheck.setString(1, phone);
            if (stCheck.executeQuery().next()) return false; // Số điện thoại đã tồn tại

            // Chèn User
            PreparedStatement stUser = connection.prepareStatement(insertUserSql);
            stUser.setString(1, fullName);
            stUser.setString(2, phone);
            stUser.setString(3, password);
            stUser.setString(4, studentId);
            stUser.executeUpdate();

            // Chèn Ví
            PreparedStatement stWallet = connection.prepareStatement(insertWalletSql);
            stWallet.executeUpdate();

            connection.commit(); // Hoàn tất
            return true;
        } catch (Exception e) {
            try { connection.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
        } finally {
            try { connection.setAutoCommit(true); } catch (Exception ex) {}
        }
        return false;
    }

    public Booking getBookingWithDriver(int bookingId) {
        String sql = "SELECT b.*, u.full_name AS driverName " +
                "FROM Bookings b " +
                "LEFT JOIN Users u ON b.driver_id = u.user_id " +
                "WHERE b.booking_id = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, bookingId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Booking b = new Booking();
                // Map các thông tin cơ bản
                b.setBookingId(rs.getInt("booking_id"));
                b.setStatus(rs.getString("status"));

                // Lấy tên tài xế từ cột Alias (driverName) trong câu SQL
                b.setDriverName(rs.getString("driverName"));

                return b;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateBookingStatus(int bookingId, String status, int driverId) {
        String sql = "UPDATE Bookings SET status = ?, driver_id = ? WHERE booking_id = ?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, driverId);
            ps.setInt(3, bookingId);

            int rowsUpdated = ps.executeUpdate();
            return rowsUpdated > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Booking> getAvailableAndMyBookings(int userId) {
        List<Booking> list = new ArrayList<>();
        // Câu SQL lấy đơn mới (pending) HOẶC đơn tài xế này đang nhận (confirmed)
        String sql = "SELECT b.*, u.full_name AS driverName " +
                "FROM Bookings b " +
                "LEFT JOIN Users u ON b.driver_id = u.user_id " +
                "WHERE b.status = 'pending' OR (b.status = 'confirmed' AND b.driver_id = ?)";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Booking b = new Booking();
                b.setBookingId(rs.getInt("booking_id"));
                b.setCustomerId(rs.getInt("customer_id"));
                b.setDriverId(rs.getInt("driver_id"));
                b.setPickupLocation(rs.getString("pickup_location"));
                b.setDropoffLocation(rs.getString("dropoff_location"));
                b.setDistanceKm((float) rs.getDouble("distance_km"));
                b.setTotalPrice(rs.getDouble("total_price"));
                b.setStatus(rs.getString("status"));
                b.setDriverName(rs.getString("driverName")); // Tên tài xế từ câu JOIN

                list.add(b);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM Users";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setPhoneNumber(rs.getString("phone_number"));
                u.setRole(rs.getString("role"));

                // --- KIỂM TRA DÒNG NÀY ---
                u.setStudentId(rs.getString("student_id"));
                // Nếu bạn quên dòng trên, u.getStudentId() sẽ luôn là null/empty

                list.add(u);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM Users WHERE user_id = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM Users WHERE user_id = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setUserId(rs.getInt("user_id"));
                u.setFullName(rs.getString("full_name"));
                u.setPhoneNumber(rs.getString("phone_number"));
                u.setEmail(rs.getString("email"));
                u.setRole(rs.getString("role"));
                u.setStudentId(rs.getString("student_id"));
                u.setStatus(rs.getString("status"));
                return u;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean checkPhoneExist(String phone) {
        String sql = "SELECT COUNT(*) AS count FROM Users WHERE phone_number = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, phone);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean registerUser(User user) {
        // Lưu ý: Chèn cả student_id vào DB
        String sql = "INSERT INTO Users (full_name, phone_number, password, role, student_id, status) VALUES (?, ?, ?, ?, ?, ?)";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhoneNumber());
            ps.setString(3, user.getPassword());
            ps.setString(4, user.getRole());
            ps.setString(5, user.getStudentId());
            ps.setString(6, user.getStatus());

            int row = ps.executeUpdate();
            if (row > 0) {
                // Sau khi tạo User thành công, tạo luôn ví tiền 0đ cho họ
                return createWallet(user.getPhoneNumber());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean createWallet(String phone) {
        // Tự động tạo ví dựa trên số điện thoại vừa đăng ký
        String sql = "INSERT INTO Wallets (user_id, balance) SELECT user_id, 0 FROM Users WHERE phone_number = ?";
        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, phone);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    public boolean updateUserAdmin(User user) {
        boolean hasPass = (user.getPassword() != null && !user.getPassword().trim().isEmpty());

        String sql = hasPass
                ? "UPDATE Users SET full_name=?, phone_number=?, student_id=?, role=?, password=? WHERE user_id=?"
                : "UPDATE Users SET full_name=?, phone_number=?, student_id=?, role=? WHERE user_id=?";

        try {
            PreparedStatement ps = connection.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhoneNumber());
            ps.setString(3, user.getStudentId());
            ps.setString(4, user.getRole());

            if (hasPass) {
                ps.setString(5, user.getPassword());
                ps.setInt(6, user.getUserId());
            } else {
                ps.setInt(5, user.getUserId());
            }

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}