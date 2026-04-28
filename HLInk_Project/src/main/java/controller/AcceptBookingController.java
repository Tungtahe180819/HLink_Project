package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/accept-booking")
public class AcceptBookingController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        int driverId = Integer.parseInt(request.getParameter("driverId"));

        UserDAO dao = new UserDAO();
        // Gọi hàm acceptBooking mà chúng ta đã viết trong UserDAO trước đó
        boolean success = dao.acceptBooking(bookingId, driverId);

        if (success) {
            response.getWriter().print("success");
        } else {
            response.getWriter().print("fail");
        }
    }
}