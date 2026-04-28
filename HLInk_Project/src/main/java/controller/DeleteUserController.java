package controller;

import dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;

import java.io.IOException;

@WebServlet(name = "DeleteUserController", urlPatterns = {"/delete-user"})
public class DeleteUserController extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                int userId = Integer.parseInt(idStr);
                UserDAO dao = new UserDAO();
                User userToDelete = dao.getUserById(userId);

                if (userToDelete != null && userToDelete.getRole().equalsIgnoreCase("admin")) {
                    response.getWriter().write("is_admin"); // Gửi phản hồi đặc biệt về cho JS
                    return;
                }
                if (dao.deleteUser(userId)) {
                    response.getWriter().write("success");
                } else if (userId == 1) {
                    response.getWriter().write("error: Cannot delete admin");
                } else {
                    response.getWriter().write("fail");
                }
            } catch (Exception e) {
                response.getWriter().write("error");
            }
        }
    }
}
