package libman.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import libman.model.Reader2;
import libman.model.ReaderCard2;

// Lớp DAO thẻ bạn đọc: lưu thẻ mới
public class ReaderCardDAO2 extends DAO2 {

    public ReaderCardDAO2() {
        super();
    }

    // Lưu thẻ bạn đọc: nhận Reader2 và ReaderCard2, sinh mã thẻ, trả về true nếu lưu được
    public boolean addReaderCard(Reader2 reader, ReaderCard2 card) {
        try {
            // Sinh mã thẻ = TH + số thứ tự kế tiếp 5 chữ số
            String code;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(MAX(CAST(SUBSTRING(cardCode, 3) AS UNSIGNED)), 0) + 1 FROM tblReaderCard2");
                 ResultSet rs = ps.executeQuery()) {
                rs.next();
                code = String.format("TH%05d", rs.getInt(1));
            }
            // Thêm thẻ vào CSDL và lấy id vừa sinh
            String sql = "INSERT INTO tblReaderCard2 (cardCode, cardType, portraitImage, issueDate, expiryDate, status, tblReader2id) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, code);
                ps.setString(2, card.getCardType());
                ps.setString(3, card.getPortraitImage());
                ps.setDate(4, new java.sql.Date(card.getIssueDate().getTime()));
                ps.setDate(5, new java.sql.Date(card.getExpiryDate().getTime()));
                ps.setString(6, card.getStatus());
                ps.setInt(7, reader.getId());
                if (ps.executeUpdate() != 1) {
                    return false;
                }
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        card.setId(keys.getInt(1));
                    }
                }
            }
            card.setCardCode(code);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { con.close(); } catch (Exception ignore) { }
        }
    }
}
