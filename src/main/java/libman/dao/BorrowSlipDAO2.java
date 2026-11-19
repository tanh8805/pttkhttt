package libman.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import libman.model.BorrowSlip2;
import libman.model.BorrowSlipDetail2;
import libman.model.BorrowableDocument2;
import libman.model.Document2;

// Lớp DAO phiếu mượn: lấy phiếu mượn theo mã tài liệu đang mượn
public class BorrowSlipDAO2 extends DAO2 {

    public BorrowSlipDAO2() {
        super();
    }

    // Lấy phiếu mượn chứa quyển đang mượn: nhận id bạn đọc và mã tài liệu, trả về BorrowSlip2 (chỉ dòng của quyển đó), không có thì trả về null
    public BorrowSlip2 getBorrowSlipByCopyCode(int idReader, String copyCode) {
        String sql = "SELECT s.id AS slipId, s.borrowCode, s.borrowDate, s.dueDate, "
                + "d.id AS detailId, "
                + "b.id AS copyId, b.copyCode, b.location, b.status, "
                + "doc.id AS docId, doc.documentCode, doc.title, doc.documentType, doc.price "
                + "FROM tblBorrowSlip2 s "
                + "JOIN tblBorrowSlipDetail2 d ON d.tblBorrowSlip2id = s.id "
                + "JOIN tblBorrowableDocument2 b ON d.tblBorrowableDocument2id = b.id "
                + "JOIN tblDocument2 doc ON b.tblDocument2id = doc.id "
                + "WHERE s.tblReader2id = ? AND b.copyCode = ? "
                + "AND NOT EXISTS (SELECT 1 FROM tblReturnReceiptDetail2 rd WHERE rd.tblBorrowSlipDetail2id = d.id) "
                + "ORDER BY s.borrowDate DESC, d.id DESC";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idReader);
            ps.setString(2, copyCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                // Đóng gói Document2 → BorrowableDocument2 → BorrowSlipDetail2 → BorrowSlip2
                Document2 doc = new Document2();
                doc.setId(rs.getInt("docId"));
                doc.setDocumentCode(rs.getString("documentCode"));
                doc.setTitle(rs.getString("title"));
                doc.setDocumentType(rs.getString("documentType"));
                doc.setPrice(rs.getFloat("price"));

                BorrowableDocument2 copy = new BorrowableDocument2();
                copy.setId(rs.getInt("copyId"));
                copy.setCopyCode(rs.getString("copyCode"));
                copy.setLocation(rs.getString("location"));
                copy.setStatus(rs.getString("status"));
                copy.setDocument(doc);

                BorrowSlipDetail2 detail = new BorrowSlipDetail2();
                detail.setId(rs.getInt("detailId"));
                detail.setBorrowableDocument(copy);

                BorrowSlip2 slip = new BorrowSlip2();
                slip.setId(rs.getInt("slipId"));
                slip.setBorrowCode(rs.getString("borrowCode"));
                slip.setBorrowDate(rs.getDate("borrowDate"));
                slip.setDueDate(rs.getDate("dueDate"));
                slip.setDetails(new BorrowSlipDetail2[]{detail});
                return slip;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            try { con.close(); } catch (Exception ignore) { }
        }
    }
}
