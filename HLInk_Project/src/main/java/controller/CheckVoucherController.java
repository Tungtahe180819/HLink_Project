package controller;

import dao.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Voucher;

@WebServlet(name = "CheckVoucherController", urlPatterns = {"/check-voucher"})
public class CheckVoucherController extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");

        String code = request.getParameter("code");
        UserDAO dao = new UserDAO();
        Voucher v = dao.getVoucherByCode(code);

        PrintWriter out = response.getWriter();

        // Tạo chuỗi JSON trả về cho JavaScript
        if (v != null) {
            out.print("{"
                    + "\"isValid\": true,"
                    + "\"percent\": " + v.getDiscountPercent() + ","
                    + "\"maxDiscount\": " + v.getMaxDiscount()
                    + "}");
        } else {
            out.print("{\"isValid\": false}");
        }
        out.flush();
    }
}