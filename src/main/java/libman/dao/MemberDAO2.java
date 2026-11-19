package libman.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import libman.model.Librarian2;
import libman.model.Member2;
import libman.model.Reader2;
import libman.model.ReaderCard2;

// Lớp DAO thành viên: kiểm tra đăng nhập
public class MemberDAO2 extends DAO2 {

    public MemberDAO2() {
        super();
    }

    // Kiểm tra đăng nhập: nhận tài khoản và mật khẩu, trả về Reader2 (kèm thẻ nếu có) hoặc Librarian2, sai thì trả về null
    public Member2 checkLogin(String username, String password) {
        String sql = "SELECT m.id, m.username, m.fullName, m.dateOfBirth, m.address, m.email, m.phoneNumber, m.role, "
                + "r.readerCode, r.unit, r.readerType, e.position, "
                + "c.id AS cardId, c.cardCode, c.cardType, c.portraitImage, c.issueDate, c.expiryDate, c.status "
                + "FROM tblMember2 m "
                + "LEFT JOIN tblReader2 r ON r.id = m.id "
                + "LEFT JOIN tblEmployee2 e ON e.id = m.id "
                + "LEFT JOIN tblReaderCard2 c ON c.tblReader2id = r.id "
                + "WHERE m.username = ? AND m.password = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                Member2 member;
                if ("Reader".equals(rs.getString("role"))) {
                    Reader2 reader = new Reader2();
                    reader.setReaderCode(rs.getString("readerCode"));
                    reader.setUnit(rs.getString("unit"));
                    reader.setReaderType(rs.getString("readerType"));
                    if (rs.getString("cardCode") != null) {
                        ReaderCard2 card = new ReaderCard2();
                        card.setId(rs.getInt("cardId"));
                        card.setCardCode(rs.getString("cardCode"));
                        card.setCardType(rs.getString("cardType"));
                        card.setPortraitImage(rs.getString("portraitImage"));
                        card.setIssueDate(rs.getDate("issueDate"));
                        card.setExpiryDate(rs.getDate("expiryDate"));
                        card.setStatus(rs.getString("status"));
                        reader.setReaderCard(card);
                    }
                    member = reader;
                } else if ("Librarian".equals(rs.getString("role"))) {
                    Librarian2 librarian = new Librarian2();
                    librarian.setPosition(rs.getString("position"));
                    member = librarian;
                } else {
                    return null;
                }
                member.setId(rs.getInt("id"));
                member.setUsername(rs.getString("username"));
                member.setFullName(rs.getString("fullName"));
                member.setDateOfBirth(rs.getDate("dateOfBirth"));
                member.setAddress(rs.getString("address"));
                member.setEmail(rs.getString("email"));
                member.setPhoneNumber(rs.getString("phoneNumber"));
                member.setRole(rs.getString("role"));
                return member;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            try { con.close(); } catch (Exception ignore) { }
        }
    }
}
