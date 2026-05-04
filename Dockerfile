# Sử dụng Tomcat bản 10.1 (phù hợp với Servlet của bạn)
FROM tomcat:10.1-jdk17

# Xóa các app mặc định
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy toàn bộ nội dung thư mục webapp vào thư mục ROOT của Tomcat
# Cách này giúp bạn không cần đóng gói file .war thủ công
COPY src/main/webapp /usr/local/tomcat/webapps/ROOT

# Chuyển các file .java đã biên dịch (nếu bạn chạy build trên render)
# Nhưng cách dễ nhất cho Tùng là:
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]
