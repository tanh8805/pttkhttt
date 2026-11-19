package libman.dao;

import java.sql.Connection;
import java.sql.DriverManager;

// Lớp DAO cơ sở: giữ thông tin kết nối MySQL, các lớp DAO khác kế thừa và dùng chung kết nối con
public class DAO2 {
    private static final String URL = "jdbc:mysql://localhost:3306/libman"
            + "?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh";
    private static final String USER = "root";
    private static final String PASSWORD = "123456";

    protected Connection con;

    // Hàm khởi tạo: nạp driver và mở kết nối tới CSDL libman
    public DAO2() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
