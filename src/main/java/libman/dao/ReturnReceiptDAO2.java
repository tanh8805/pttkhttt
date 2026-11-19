package libman.dao;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import libman.model.Fine2;
import libman.model.ReturnReceipt2;
import libman.model.ReturnReceiptDetail2;

// Lớp DAO phiếu trả: lưu phiếu trả
public class ReturnReceiptDAO2 extends DAO2 {

    public ReturnReceiptDAO2() {
        super();
    }

    // Lưu phiếu trả, dòng trả, khoản phạt và cập nhật trạng thái tài liệu trong một giao dịch: nhận ReturnReceipt2, trả về true nếu lưu được
    public boolean saveReturnReceipt(ReturnReceipt2 receipt) {
        try {
            con.setAutoCommit(false);

            // Sinh mã phiếu trả = PT + số thứ tự kế tiếp 5 chữ số
            String code;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT COALESCE(MAX(CAST(SUBSTRING(returnCode, 3) AS UNSIGNED)), 0) + 1 FROM tblReturnReceipt2 FOR UPDATE");
                 ResultSet rs = ps.executeQuery()) {
                rs.next();
                code = String.format("PT%05d", rs.getInt(1));
            }

            // Lưu phiếu trả
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO tblReturnReceipt2 (returnCode, returnDate, tblReader2id, tblEmployee2id) VALUES (?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, code);
                ps.setDate(2, new java.sql.Date(receipt.getReturnDate().getTime()));
                ps.setInt(3, receipt.getReader().getId());
                ps.setInt(4, receipt.getLibrarian().getId());
                ps.executeUpdate();
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    keys.next();
                    receipt.setId(keys.getInt(1));
                }
            }

            for (ReturnReceiptDetail2 detail : receipt.getDetails()) {
                // Lưu dòng trả
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO tblReturnReceiptDetail2 (tblReturnReceipt2id, tblBorrowSlipDetail2id) VALUES (?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, receipt.getId());
                    ps.setInt(2, detail.getBorrowSlipDetail().getId());
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        keys.next();
                        detail.setId(keys.getInt(1));
                    }
                }

                // Lưu các khoản phạt của dòng trả, có phạt hỏng hóc thì đánh dấu để đổi trạng thái tài liệu
                boolean damaged = false;
                for (Fine2 fine : detail.getFines()) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "INSERT INTO tblFine2 (fineType, amount, reason, tblReturnReceiptDetail2id) VALUES (?, ?, ?, ?)",
                            Statement.RETURN_GENERATED_KEYS)) {
                        ps.setString(1, fine.getFineType());
                        ps.setFloat(2, fine.getAmount());
                        ps.setString(3, fine.getReason());
                        ps.setInt(4, detail.getId());
                        ps.executeUpdate();
                        try (ResultSet keys = ps.getGeneratedKeys()) {
                            keys.next();
                            fine.setId(keys.getInt(1));
                        }
                    }
                    if ("Hỏng hóc".equals(fine.getFineType())) {
                        damaged = true;
                    }
                }

                // Cập nhật trạng thái tài liệu: hỏng hóc thì Chờ xử lí, không thì Trong kho
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE tblBorrowableDocument2 SET status = ? WHERE id = ?")) {
                    ps.setString(1, damaged ? "Chờ xử lí" : "Trong kho");
                    ps.setInt(2, detail.getBorrowSlipDetail().getBorrowableDocument().getId());
                    ps.executeUpdate();
                }
            }

            con.commit();
            receipt.setReturnCode(code);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            try { con.rollback(); } catch (Exception ignore) { }
            return false;
        } finally {
            try { con.setAutoCommit(true); } catch (Exception ignore) { }
            try { con.close(); } catch (Exception ignore) { }
        }
    }
}
