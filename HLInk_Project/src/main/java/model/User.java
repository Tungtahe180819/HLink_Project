package model;

import java.sql.Timestamp;

public class User {
    private int userId;
    private String fullName;
    private String phoneNumber;
    private String email;
    private String password;
    private String role; // 'customer', 'driver', 'admin'
    private String studentId;
    private String status; // 'active', 'inactive'
    private Timestamp createdAt;

    // Constructor không tham số (Bắt buộc phải có)
    public User() {
    }

    // Constructor đầy đủ tham số (Dùng khi cần tạo nhanh đối tượng)
    public User(int userId, String fullName, String phoneNumber, String email, String password, String role, String studentId, String status, Timestamp createdAt) {
        this.userId = userId;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.password = password;
        this.role = role;
        this.studentId = studentId;
        this.status = status;
        this.createdAt = createdAt;
    }

    // --- GETTER VÀ SETTER ---
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
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

    // Hàm toString để hỗ trợ Debug nhanh trong Console
    @Override
    public String toString() {
        return "User{" + "userId=" + userId + ", fullName=" + fullName + ", role=" + role + ", status=" + status + '}';
    }
}