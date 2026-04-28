package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/book") // Đảm bảo annotation này khớp với URL trong fetch
public class BookingController extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Thiết lập encoding để tránh lỗi tiếng Việt
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        try {
            // Trong file BookingController.java
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            // Sửa đoạn này trong try-catch của BookingController
            String serviceType = request.getParameter("serviceType");

// Kiểm tra an toàn trước khi dùng .contains()
            int serviceId = 1; // Mặc định là 1 (Xe ôm)
            if (serviceType != null && serviceType.contains("10000")) {
                serviceId = 2; // Nếu là 10k thì là Ship đồ
            }

            String pickup = request.getParameter("pickup");
            String dropoff = request.getParameter("dropoff");

// Kiểm tra null cho distance để tránh lỗi ParseFloat
            String distParam = request.getParameter("distance");
            float distance = (distParam != null) ? Float.parseFloat(distParam.replace(" km", "")) : 0;

            String amountParam = request.getParameter("amount");
            double total = (amountParam != null) ? Double.parseDouble(amountParam.replace(",", "")) : 0;
            UserDAO dao = new UserDAO();
// Truyền ĐỦ các biến vào đây
            boolean success = dao.createBooking(customerId, serviceId, pickup, dropoff, distance, total);

            if (success) {
                response.getWriter().print("success");
            } else {
                response.getWriter().print("fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().print("error: " + e.getMessage());
        }
    }
}