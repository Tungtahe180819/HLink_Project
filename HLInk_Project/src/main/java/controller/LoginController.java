package controller;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        String phone = request.getParameter("phone");
        String password = request.getParameter("pass");

        UserDAO dao = new UserDAO();

        try {
            User u = dao.login(phone, password);
            if (u != null) {
                request.getSession().setAttribute("account", u);
                if (u.getRole().equalsIgnoreCase("admin")) {
                    response.sendRedirect("admin-manager");
                } else if ("customer".equalsIgnoreCase(u.getRole())) {
                    response.sendRedirect("customer.jsp");
                } else {
                    response.sendRedirect("driver.jsp");
                }
                return;
            } else {
                // Sai tài khoản/mật khẩu
                request.setAttribute("loginError", "true");
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Cho dù lỗi DB thì cũng báo loginError để hiện popup cho người dùng
            request.setAttribute("loginError", "true");
        }

        // Quay về login.jsp
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }
}