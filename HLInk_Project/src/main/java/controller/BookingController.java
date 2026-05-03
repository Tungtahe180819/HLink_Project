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
            // 1. Lấy customerId
            String customerIdStr = request.getParameter("customerId");
            if (customerIdStr == null) {
                response.getWriter().print("error: Thiếu Customer ID");
                return;
            }
            int customerId = Integer.parseInt(customerIdStr);

            // 2. Xác định loại dịch vụ (serviceId)
            String serviceType = request.getParameter("serviceType");
            int serviceId = 1; // Mặc định là 1 (Xe ôm)
            if (serviceType != null && serviceType.contains("10000")) {
                serviceId = 2; // Ship đồ
            }

            // 3. Lấy thông tin điểm đi/đến
            String pickup = request.getParameter("pickup");
            String dropoff = request.getParameter("dropoff");

            // 4. Xử lý khoảng cách
            String distParam = request.getParameter("distance");
            float distance = (distParam != null) ? Float.parseFloat(distParam.replace(" km", "").trim()) : 0;

            // --- PHẦN ĐỒNG BỘ VOUCHER ---
            // Ưu tiên lấy 'totalPrice' (giá đã trừ voucher từ JS gửi về)
            // Nếu không có 'totalPrice' thì mới dùng 'amount' cũ
            String totalPriceParam = request.getParameter("totalPrice");
            String amountParam = request.getParameter("amount");

            double total = 0;
            if (totalPriceParam != null && !totalPriceParam.isEmpty()) {
                total = Double.parseDouble(totalPriceParam);
            } else if (amountParam != null && !amountParam.isEmpty()) {
                total = Double.parseDouble(amountParam.replace(",", "").trim());
            }

            // Lấy thêm mã voucher (nếu Tùng muốn lưu vết vào DB sau này)
            String appliedVoucher = request.getParameter("appliedVoucher");
            // ----------------------------

            // 5. Gọi DAO để tạo Booking
            UserDAO dao = new UserDAO();
            // Đảm bảo hàm createBooking trong UserDAO nhận tham số total là giá cuối cùng
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