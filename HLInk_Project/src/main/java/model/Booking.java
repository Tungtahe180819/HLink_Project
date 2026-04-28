package model;

import java.sql.Timestamp;

public class Booking {
    private int bookingId;
    private int customerId;
    private Integer driverId; // Dùng Integer thay vì int để có thể nhận giá trị null
    private int serviceId;
    private String pickupLocation;
    private String dropoffLocation;
    private float distanceKm;
    private double totalPrice;
    private String status;
    private Timestamp createdAt;
    private String driverName;

    public Booking() {
    }

    public Booking(int bookingId, int customerId, Integer driverId, int serviceId, String pickupLocation, String dropoffLocation, float distanceKm, double totalPrice, String status, Timestamp createdAt, String driverName) {
        this.bookingId = bookingId;
        this.customerId = customerId;
        this.driverId = driverId;
        this.serviceId = serviceId;
        this.pickupLocation = pickupLocation;
        this.dropoffLocation = dropoffLocation;
        this.distanceKm = distanceKm;
        this.totalPrice = totalPrice;
        this.status = status;
        this.createdAt = createdAt;
        this.driverName = driverName;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public Integer getDriverId() {
        return driverId;
    }

    public void setDriverId(Integer driverId) {
        this.driverId = driverId;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getPickupLocation() {
        return pickupLocation;
    }

    public void setPickupLocation(String pickupLocation) {
        this.pickupLocation = pickupLocation;
    }

    public String getDropoffLocation() {
        return dropoffLocation;
    }

    public void setDropoffLocation(String dropoffLocation) {
        this.dropoffLocation = dropoffLocation;
    }

    public float getDistanceKm() {
        return distanceKm;
    }

    public void setDistanceKm(float distanceKm) {
        this.distanceKm = distanceKm;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getDriverName() {
        return driverName;
    }

    public void setDriverName(String driverName) {
        this.driverName = driverName;
    }
}