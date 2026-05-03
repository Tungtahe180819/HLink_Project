package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import dao.UserDAO;

import java.io.IOException;

@WebServlet(name = "ForgotPasswordController", urlPatterns = {"/forgot-password"})
public class ForgotPasswordController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy thông tin từ form gửi lên
        String studentId = request.getParameter("studentId");
        String phoneNumber = request.getParameter("phoneNumber");
        String newPassword = request.getParameter("newPassword");

        // 2. Kiểm tra sơ bộ (Validation)
        if (studentId == null || phoneNumber == null || newPassword == null ||
                studentId.isEmpty() || phoneNumber.isEmpty() || newPassword.isEmpty()) {

            request.setAttribute("error", "Vui lòng nhập đầy đủ tất cả các trường!");
            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
            return;
        }

        // 3. Gọi DAO để thực hiện cập nhật trong Database
        UserDAO dao = new UserDAO();
        // Hàm resetPassword này Tùng đã thêm vào UserDAO ở bước trước nhé
        boolean isUpdated = dao.resetPassword(studentId, phoneNumber, newPassword);

        if (isUpdated) {
            // 4. Nếu thành công:
            // Gửi thông báo thành công về trang Login để người dùng biết
            request.setAttribute("successMessage", "Khôi phục mật khẩu thành công! Hãy đăng nhập bằng mật khẩu mới.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            // 5. Nếu thất bại (Thông tin MSSV hoặc SĐT không khớp):
            // Gửi thông báo lỗi quay lại trang quên mật khẩu
            request.setAttribute("error", "Thông tin MSSV hoặc Số điện thoại không chính xác!");
            // Giữ lại thông tin cũ để người dùng không phải nhập lại (trừ mật khẩu)
            request.setAttribute("oldStudentId", studentId);
            request.setAttribute("oldPhone", phoneNumber);

            request.getRequestDispatcher("forgot-password.jsp").forward(request, response);
        }
    }
}