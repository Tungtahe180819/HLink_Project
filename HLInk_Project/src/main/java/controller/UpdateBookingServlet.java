package controller;

import dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import java.io.IOException;


@WebServlet("/update-booking")
public class UpdateBookingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("text/plain;charset=UTF-8");

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            String status = request.getParameter("status"); // "confirmed" hoặc "completed"

            // Lấy Driver đang đăng nhập từ Session
            HttpSession session = request.getSession();
            User driver = (User) session.getAttribute("account");

            UserDAO dao = new UserDAO();
            // Cập nhật trạng thái và gán driver_id cho đơn hàng
            boolean success = dao.updateBookingStatus(bookingId, status, driver.getUserId());

            if (success) {
                response.getWriter().write("success");
            } else {
                response.getWriter().write("fail");
            }
        } catch (Exception e) {
            response.getWriter().write("error");
        }
    }
}