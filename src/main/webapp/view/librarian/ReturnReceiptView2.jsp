<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.dao.*, libman.model.*, java.time.LocalDate" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang phiếu trả: hiển thị phiếu trả, bấm Lưu để lưu và in phiếu
    // Lấy nhân viên đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Librarian2 librarian = (Librarian2) session.getAttribute("librarian");
    if (librarian == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }
    // Lấy bạn đọc và danh sách tài liệu trả từ session, thiếu thì về trang chủ nhân viên
    Reader2 reader = (Reader2) session.getAttribute("reader");
    ReturnReceiptDetail2[] listDetail = (ReturnReceiptDetail2[]) session.getAttribute("listDetail");
    BorrowSlip2[] listBorrowSlip = (BorrowSlip2[]) session.getAttribute("listBorrowSlip");
    if (reader == null || listDetail == null || listBorrowSlip == null) {
        response.sendRedirect(request.getContextPath() + "/view/librarian/LibrarianHomeView2.jsp");
        return;
    }

    // Tính tổng tiền phạt rồi đóng gói ReturnReceipt2 (ngày trả là hôm nay)
    float totalFine = 0;
    for (int i = 0; i < listDetail.length; i++) {
        for (Fine2 fine : listDetail[i].getFines()) {
            totalFine = totalFine + fine.getAmount();
        }
    }
    ReturnReceipt2 receipt = new ReturnReceipt2();
    receipt.setReader(reader);
    receipt.setLibrarian(librarian);
    receipt.setReturnDate(java.sql.Date.valueOf(LocalDate.now()));
    receipt.setDetails(listDetail.clone());
    receipt.setTotalFine(totalFine);

    String action = request.getParameter("action");
    boolean saved = false;
    String outError = "";

    if (action != null && action.equals("quaylai")) {
        // Bấm Quay lại: về trang nhận trả tài liệu
        response.sendRedirect(request.getContextPath() + "/view/librarian/ReturnDocumentView2.jsp");
        return;
    } else if (action != null && action.equals("luu")) {
        // Bấm Lưu: lưu phiếu trả, thành công thì xoá dữ liệu nhận trả khỏi session
        if (listDetail.length == 0) {
            outError = "Chưa có tài liệu trả, vui lòng quét mã tài liệu";
        } else {
            ReturnReceiptDAO2 returnReceiptDAO = new ReturnReceiptDAO2();
            saved = returnReceiptDAO.saveReturnReceipt(receipt);
            if (saved) {
                session.removeAttribute("reader");
                session.removeAttribute("listDetail");
                session.removeAttribute("listBorrowSlip");
            } else {
                outError = "Lỗi lưu dữ liệu, không lưu được phiếu trả. Vui lòng bấm Lưu lại";
            }
        }
    } else if (listDetail.length == 0) {
        outError = "Chưa có tài liệu trả, vui lòng quét mã tài liệu";
    }

    // Chuẩn bị giá trị hiển thị
    String errorDisplay = "none";
    if (!outError.isEmpty()) {
        errorDisplay = "block";
    }
    String savedDisplay = "none";
    String savedBlock = "none";
    String saveDisplay = "inline-block";
    String outReturnCode = "";
    if (saved) {
        savedDisplay = "flex";
        savedBlock = "block";
        saveDisplay = "none";
        outReturnCode = receipt.getReturnCode();
    }
    String outReturnDate = fmtDate(receipt.getReturnDate());
    String outReaderName = receipt.getReader().getFullName();
    String outCardCode = receipt.getReader().getReaderCard().getCardCode();
    String outLibrarianName = receipt.getLibrarian().getFullName();
    float outTotalFine = receipt.getTotalFine();
    ReturnReceiptDetail2[] rows = receipt.getDetails();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Phiếu trả</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Nhân viên: " + librarian.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Phiếu trả</h1>
        <div style="margin:0 0 16px 0;padding:10px 14px;background:#dcfce7;color:#166534;border:1px solid #bbf7d0;border-radius:6px;font-weight:bold;display:<%= savedBlock %>;">Nhận trả tài liệu thành công. Mã phiếu trả: <%= esc(outReturnCode) %></div>
        <div data-frame="receipt">
        <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:6px 20px;margin-bottom:16px;">
            <div style="display:<%= savedDisplay %>;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã phiếu trả:</div><div><%= esc(outReturnCode) %></div></div>
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Ngày trả:</div><div id="outReturnDate"><%= esc(outReturnDate) %></div></div>
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Bạn đọc:</div><div id="outReaderName"><%= esc(outReaderName) %></div></div>
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã thẻ:</div><div id="outCardCode"><%= esc(outCardCode) %></div></div>
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Nhân viên lập:</div><div id="outLibrarianName"><%= esc(outLibrarianName) %></div></div>
        </div>
        <table id="tblReturn" style="width:100%;border-collapse:collapse;margin:16px 0;">
            <tr>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">TT</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Mã tài liệu cho mượn</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Tên tài liệu</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Mã phiếu mượn</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Ngày hẹn trả</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:right;font-size:14px;font-weight:bold;">Phạt trả chậm (đồng)</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:right;font-size:14px;font-weight:bold;">Phạt hỏng hóc (đồng)</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:right;font-size:14px;font-weight:bold;">Cộng (đồng)</th>
            </tr>
            <%
                for (int i = 0; i < rows.length; i++) {
                    BorrowableDocument2 copy = rows[i].getBorrowSlipDetail().getBorrowableDocument();
                    BorrowSlip2 slip = listBorrowSlip[i];
                    float lateFine = 0;
                    float damageFine = 0;
                    for (Fine2 fine : rows[i].getFines()) {
                        if (fine.getFineType().equals("Trả chậm")) {
                            lateFine = lateFine + fine.getAmount();
                        } else {
                            damageFine = damageFine + fine.getAmount();
                        }
                    }
            %>
            <tr>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;"><%= i + 1 %></td>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;"><%= esc(copy.getCopyCode()) %></td>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;"><%= esc(copy.getDocument().getTitle()) %></td>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;"><%= esc(slip.getBorrowCode()) %></td>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;"><%= fmtDate(slip.getDueDate()) %></td>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;text-align:right;"><%= money(lateFine) %></td>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;text-align:right;"><%= money(damageFine) %></td>
                <td style="padding:12px 8px;border-bottom:1px solid #e5e7eb;font-size:14px;text-align:right;"><%= money(lateFine + damageFine) %></td>
            </tr>
            <% } %>
        </table>
        <p style="margin:0 0 16px 0;font-weight:bold;">Tổng tiền phạt (đồng): <span id="outTotalFine"><%= money(outTotalFine) %></span></p>
        </div>
        <div id="outError" style="margin:16px 0;padding:10px 14px;background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;border-radius:6px;display:<%= errorDisplay %>;"><%= esc(outError) %></div>
        <form method="post" style="display:<%= saveDisplay %>;">
            <input type="hidden" name="action" value="luu">
            <button type="submit" id="btnSave" style="height:42px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Lưu</button>
        </form>
        <form method="post">
            <input type="hidden" name="action" value="quaylai">
            <button type="submit" id="btnBack" style="position:absolute;top:24px;right:24px;height:42px;padding:0 20px;background:#ffffff;color:#374151;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Quay lại</button>
        </form>
    </div>
</div>
<% if (saved) { %>
<script>
    // In khung phiếu trả rồi trả lại trang như cũ
    var pageHtml = document.body.innerHTML;
    var frame = document.querySelector('[data-frame=receipt]');
    document.body.innerHTML = '<div style="margin:20px;font-family:Arial,Helvetica,sans-serif;">'
        + '<h2 style="text-align:center;">PHIẾU TRẢ TÀI LIỆU</h2>' + frame.outerHTML + '</div>';
    window.print();
    document.body.innerHTML = pageHtml;
</script>
<% } %>
</body>
</html>
