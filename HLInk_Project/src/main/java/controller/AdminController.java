package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Booking;
import model.User;

import java.io.IOException;
import java.util.List;


@WebServlet(name = "AdminController", urlPatterns = {"/admin-manager"})
public class AdminController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Kiểm tra quyền Admin trước khi cho vào
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("account");

        // Kiểm tra quyền Admin
        if (user == null || !user.getRole().equalsIgnoreCase("admin")) {
            response.sendRedirect("login.jsp");
            return;
        }

        UserDAO dao = new UserDAO();
        List<Booking> allList = dao.getAllBookings();
        List<User> userList = dao.getAllUsers();

        // Đẩy dữ liệu sang trang JSP
        request.setAttribute("allList", allList);
        request.setAttribute("userList", userList);

        request.getRequestDispatcher("admin.jsp").forward(request, response);
    }
}