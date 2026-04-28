package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBContext {
    protected Connection connection;

    public DBContext() {
        try {
            String user = "root";
            String pass = "Iloveyou1612"; // THAY MẬT KHẨU CỦA BẠN VÀO ĐÂY
            String url = "jdbc:mysql://localhost:3306/hlink_db?useSSL=false&allowPublicKeyRetrieval=true";
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(url, user, pass);
        } catch (Exception ex) {
            System.out.println("Lỗi kết nối DB: " + ex.getMessage());
        }
    }
}