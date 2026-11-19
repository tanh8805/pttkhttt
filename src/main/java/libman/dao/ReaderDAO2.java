package libman.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import libman.model.Reader2;
import libman.model.ReaderCard2;

// Lớp DAO bạn đọc: cập nhật thông tin và tìm bạn đọc theo mã thẻ
public class ReaderDAO2 extends DAO2 {

    public ReaderDAO2() {
        super();
    }

    // Cập nhật số điện thoại, địa chỉ của bạn đọc: nhận Reader2, trả về true nếu cập nhật được
    public boolean updateReader(Reader2 reader) {
        String sql = "UPDATE tblMember2 SET phoneNumber = ?, address = ? WHERE id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, reader.getPhoneNumber());
            ps.setString(2, reader.getAddress());
            ps.setInt(3, reader.getId());
            return ps.executeUpdate() == 1;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            try { con.close(); } catch (Exception ignore) { }
        }
    }

    // Tìm bạn đọc kèm thẻ theo mã thẻ: nhận mã thẻ, trả về Reader2 có readerCard, không có thì trả về null
    public Reader2 getReaderByCardCode(String cardCode) {
        String sql = "SELECT m.id, m.username, m.fullName, m.dateOfBirth, m.address, m.email, m.phoneNumber, m.role, "
                + "r.readerCode, r.unit, r.readerType, "
                + "c.id AS cardId, c.cardCode, c.cardType, c.portraitImage, c.issueDate, c.expiryDate, c.status "
                + "FROM tblReaderCard2 c "
                + "JOIN tblReader2 r ON c.tblReader2id = r.id "
                + "JOIN tblMember2 m ON r.id = m.id "
                + "WHERE c.cardCode = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, cardCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                // Đóng gói ReaderCard2 → Reader2
                ReaderCard2 card = new ReaderCard2();
                card.setId(rs.getInt("cardId"));
                card.setCardCode(rs.getString("cardCode"));
                card.setCardType(rs.getString("cardType"));
                card.setPortraitImage(rs.getString("portraitImage"));
                card.setIssueDate(rs.getDate("issueDate"));
                card.setExpiryDate(rs.getDate("expiryDate"));
                card.setStatus(rs.getString("status"));

                Reader2 reader = new Reader2();
                reader.setId(rs.getInt("id"));
                reader.setUsername(rs.getString("username"));
                reader.setFullName(rs.getString("fullName"));
                reader.setDateOfBirth(rs.getDate("dateOfBirth"));
                reader.setAddress(rs.getString("address"));
                reader.setEmail(rs.getString("email"));
                reader.setPhoneNumber(rs.getString("phoneNumber"));
                reader.setRole(rs.getString("role"));
                reader.setReaderCode(rs.getString("readerCode"));
                reader.setUnit(rs.getString("unit"));
                reader.setReaderType(rs.getString("readerType"));
                reader.setReaderCard(card);
                return reader;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            try { con.close(); } catch (Exception ignore) { }
        }
    }
}
