package controller;

import dao.UserDAO;
import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

@WebServlet(name = "EditUserController", urlPatterns = {"/edit-user"})
public class EditUserController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String userIdRaw = request.getParameter("userId");
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String studentId = request.getParameter("studentId");
        String role = request.getParameter("role");
        String password = request.getParameter("password");

        // KIỂM TRA BẮT BUỘC: Nếu các trường chính bị rỗng, không cho Update
        if (fullName == null || fullName.trim().isEmpty() ||
                phone == null || phone.trim().isEmpty() ||
                studentId == null || studentId.trim().isEmpty()) {

            response.sendRedirect("admin-manager?status=invalid_input");
            return;
        }

        User userUpdate = new User();
        userUpdate.setUserId(Integer.parseInt(userIdRaw));
        userUpdate.setFullName(fullName);
        userUpdate.setPhoneNumber(phone);
        userUpdate.setStudentId(studentId);
        userUpdate.setRole(role);
        userUpdate.setPassword(password);

        UserDAO dao = new UserDAO();
        boolean success = dao.updateUserAdmin(userUpdate);

        if (success) {
            response.sendRedirect("admin-manager?status=success");
        } else {
            response.sendRedirect("admin-manager?status=error");
        }
    }
}