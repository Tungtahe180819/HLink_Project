package util;

import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        try {
            // Khởi tạo đối tượng DBContext
            DBContext db = new DBContext();

            // Lấy connection từ thuộc tính 'connection' của DBContext
            Connection conn = db.connection;

            if (conn != null && !conn.isClosed()) {
                System.out.println("==========================================");
                System.out.println(" KẾT NỐI DATABASE THÀNH CÔNG RỰC RỠ! ");
                System.out.println(" Bạn đã có thể bắt đầu làm chức năng Login.");
                System.out.println("==========================================");
            } else {
                System.out.println("Xảy ra lỗi: Connection đang bị null hoặc đóng.");
            }
        } catch (Exception e) {
            System.err.println("LỖI KẾT NỐI: " + e.getMessage());
            e.printStackTrace();
        }
    }
}