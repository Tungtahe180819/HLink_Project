package model;

import java.sql.Date;

public class Voucher {
    private int voucherId;
    private String voucherCode;
    private int discountPercent;
    private double maxDiscount;
    private Date expiryDate;
    private boolean isActive;

    // Constructor không tham số (mặc định)
    public Voucher() {
    }

    // Constructor đầy đủ tham số
    public Voucher(int voucherId, String voucherCode, int discountPercent, double maxDiscount, Date expiryDate, boolean isActive) {
        this.voucherId = voucherId;
        this.voucherCode = voucherCode;
        this.discountPercent = discountPercent;
        this.maxDiscount = maxDiscount;
        this.expiryDate = expiryDate;
        this.isActive = isActive;
    }

    // Getter và Setter
    public int getVoucherId() {
        return voucherId;
    }

    public void setVoucherId(int voucherId) {
        this.voucherId = voucherId;
    }

    public String getVoucherCode() {
        return voucherCode;
    }

    public void setVoucherCode(String voucherCode) {
        this.voucherCode = voucherCode;
    }

    public int getDiscountPercent() {
        return discountPercent;
    }

    public void setDiscountPercent(int discountPercent) {
        this.discountPercent = discountPercent;
    }

    public double getMaxDiscount() {
        return maxDiscount;
    }

    public void setMaxDiscount(double maxDiscount) {
        this.maxDiscount = maxDiscount;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    // Ghi đè phương thức toString để dễ dàng debug khi cần
    @Override
    public String toString() {
        return "Voucher{" + "voucherCode=" + voucherCode + ", discountPercent=" + discountPercent + "%}";
    }
}
