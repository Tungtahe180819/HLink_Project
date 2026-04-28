package controller;

import dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Booking;
import java.io.IOException;


@WebServlet("/check-booking-status")
public class CheckStatusController extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");

        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            UserDAO dao = new UserDAO();

            // Hàm này lấy status và tên tài xế (sẽ bổ sung ở DAO dưới đây)
            Booking b = dao.getBookingWithDriver(bookingId);

            if (b != null) {
                String json = String.format(
                        "{\"status\":\"%s\", \"driverName\":\"%s\"}",
                        b.getStatus(),
                        (b.getDriverName() != null ? b.getDriverName() : "")
                );
                response.getWriter().write(json);
            }
        } catch (Exception e) {
            response.getWriter().write("{\"status\":\"error\"}");
        }
    }
}