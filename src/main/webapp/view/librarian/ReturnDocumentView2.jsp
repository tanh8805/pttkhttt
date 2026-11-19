<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.model.*" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang nhận trả tài liệu: hiển thị bạn đọc và danh sách tài liệu trả, từ đây sang quét tài liệu hoặc in phiếu trả
    // Lấy nhân viên đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Librarian2 librarian = (Librarian2) session.getAttribute("librarian");
    if (librarian == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }
    // Lấy bạn đọc từ session, chưa quét thẻ thì về trang quét thẻ
    Reader2 reader = (Reader2) session.getAttribute("reader");
    if (reader == null) {
        response.sendRedirect(request.getContextPath() + "/view/librarian/FindReaderView2.jsp");
        return;
    }
    // Lấy danh sách dòng trả và danh sách phiếu mượn tương ứng, chưa có thì tạo danh sách rỗng
    ReturnReceiptDetail2[] listDetail = (ReturnReceiptDetail2[]) session.getAttribute("listDetail");
    if (listDetail == null) {
        listDetail = new ReturnReceiptDetail2[0];
        session.setAttribute("listDetail", listDetail);
    }
    BorrowSlip2[] listBorrowSlip = (BorrowSlip2[]) session.getAttribute("listBorrowSlip");
    if (listBorrowSlip == null) {
        listBorrowSlip = new BorrowSlip2[0];
        session.setAttribute("listBorrowSlip", listBorrowSlip);
    }

    String action = request.getParameter("action");
    String outError = "";

    if (action != null && action.equals("quaylai")) {
        // Bấm Quay lại: bỏ danh sách tài liệu trả, về trang quét thẻ
        session.removeAttribute("listDetail");
        session.removeAttribute("listBorrowSlip");
        session.removeAttribute("borrowSlip");
        session.removeAttribute("fine");
        response.sendRedirect(request.getContextPath() + "/view/librarian/FindReaderView2.jsp");
        return;
    } else if (action != null && action.equals("in")) {
        // Bấm In phiếu trả: có tài liệu trả thì sang trang phiếu trả
        if (listDetail.length == 0) {
            outError = "Chưa có tài liệu trả, vui lòng quét mã tài liệu";
        } else {
            response.sendRedirect(request.getContextPath() + "/view/librarian/ReturnReceiptView2.jsp");
            return;
        }
    }

    // Chuẩn bị giá trị hiển thị
    String errorDisplay = "none";
    if (!outError.isEmpty()) {
        errorDisplay = "block";
    }
    String outCardCode = reader.getReaderCard().getCardCode();
    String outFullName = reader.getFullName();
    String outStudentCode = reader.getReaderCode();
    String outExpiryDate = fmtDate(reader.getReaderCard().getExpiryDate());
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Nhận trả tài liệu</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Nhân viên: " + librarian.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Nhận trả tài liệu</h1>
        <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:6px 20px;margin-bottom:16px;">
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã thẻ:</div><div id="outCardCode"><%= esc(outCardCode) %></div></div>
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Họ tên:</div><div id="outFullName"><%= esc(outFullName) %></div></div>
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã sinh viên:</div><div id="outStudentCode"><%= esc(outStudentCode) %></div></div>
            <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Ngày hết hạn thẻ:</div><div id="outExpiryDate"><%= esc(outExpiryDate) %></div></div>
        </div>
        <div style="margin:0 0 8px 0;font-weight:bold;">Danh sách tài liệu trả:</div>
        <table id="tblReturn" style="width:100%;border-collapse:collapse;margin:8px 0 16px 0;">
            <tr>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">TT</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Mã tài liệu cho mượn</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Tên tài liệu</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Mã phiếu mượn</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:left;font-size:14px;font-weight:bold;">Ngày hẹn trả</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:right;font-size:14px;font-weight:bold;">Phạt trả chậm (đồng)</th>
                <th style="padding:12px 8px;background:#f9fafb;border-bottom:1px solid #e5e7eb;text-align:right;font-size:14px;font-weight:bold;">Phạt hỏng hóc (đồng)</th>
            </tr>
            <%
                // Mỗi dòng trả: cộng riêng phạt trả chậm và phạt hỏng hóc
                for (int i = 0; i < listDetail.length; i++) {
                    BorrowableDocument2 copy = listDetail[i].getBorrowableDocument();
                    BorrowSlip2 slip = listBorrowSlip[i];
                    float lateFine = 0;
                    float damageFine = 0;
                    for (Fine2 fine : listDetail[i].getFines()) {
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
            </tr>
            <% } %>
        </table>
        <div id="outError" style="margin:16px 0;padding:10px 14px;background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;border-radius:6px;display:<%= errorDisplay %>;"><%= esc(outError) %></div>
        <form method="post" action="<%= request.getContextPath() %>/view/librarian/ScanDocumentView2.jsp" style="display:inline;">
            <button type="submit" id="btnScanDocument" style="height:42px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Quét mã tài liệu</button>
        </form>
        <form method="post" style="display:inline;">
            <input type="hidden" name="action" value="in">
            <button type="submit" id="btnPrint" style="height:42px;margin-left:8px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">In phiếu trả</button>
        </form>
        <form method="post">
            <input type="hidden" name="action" value="quaylai">
            <button type="submit" id="btnBack" style="position:absolute;top:24px;right:24px;height:42px;padding:0 20px;background:#ffffff;color:#374151;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Quay lại</button>
        </form>
    </div>
</div>
</body>
</html>
