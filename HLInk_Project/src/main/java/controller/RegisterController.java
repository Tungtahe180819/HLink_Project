package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.io.IOException;

@WebServlet("/register")
public class RegisterController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Lấy dữ liệu từ Form
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String studentId = request.getParameter("studentId");
        String role = request.getParameter("role");

        // 2. Tạo đối tượng User để lưu trữ
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setPhoneNumber(phone);
        newUser.setPassword(password);
        newUser.setStudentId(studentId);
        newUser.setRole(role);
        newUser.setStatus("active"); // Mặc định tài khoản mới là active

        UserDAO dao = new UserDAO();

        // 3. Kiểm tra xem số điện thoại đã tồn tại chưa
        if (dao.checkPhoneExist(phone)) {
            request.setAttribute("error", "Số điện thoại này đã có người sử dụng!");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } else {
            // 4. Thực hiện lưu vào Database
            if (dao.registerUser(newUser)) {
                // Đăng ký thành công, đẩy sang trang login
                response.sendRedirect("login.jsp?msg=success");
            } else {
                request.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
        }
    }
}