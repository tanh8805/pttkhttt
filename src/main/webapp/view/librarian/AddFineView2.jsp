<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.model.*, java.util.Objects" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang bổ sung tiền phạt: nhập số tiền và lí do phạt hỏng hóc cho tài liệu đang quét
    // Lấy nhân viên đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Librarian2 librarian = (Librarian2) session.getAttribute("librarian");
    if (librarian == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }
    // Lấy tài liệu đang quét từ session, chưa có thì về trang quét tài liệu
    BorrowSlip2 borrowSlip = (BorrowSlip2) session.getAttribute("borrowSlip");
    if (borrowSlip == null) {
        response.sendRedirect(request.getContextPath() + "/view/librarian/ScanDocumentView2.jsp");
        return;
    }

    String action = request.getParameter("action");
    BorrowableDocument2 copy = borrowSlip.getDetails()[0].getBorrowableDocument();
    String outFineType = "Hỏng hóc";
    String inAmount = "";
    String inReason = "";
    String outError = "";

    if (action != null && action.equals("quaylai")) {
        // Bấm Quay lại: về trang quét tài liệu
        response.sendRedirect(request.getContextPath() + "/view/librarian/ScanDocumentView2.jsp");
        return;
    } else if (action != null && action.equals("luu")) {
        // Bấm Lưu: kiểm tra số tiền, lí do rồi tạo khoản phạt hỏng hóc
        inAmount = Objects.toString(request.getParameter("inAmount"), "").trim();
        inReason = Objects.toString(request.getParameter("inReason"), "").trim();
        float amount = 0;
        if (inAmount.matches("\\d+(\\.\\d+)?")) {
            amount = Float.parseFloat(inAmount);
        }

        if (amount <= 0) {
            outError = "Tiền phạt phải lớn hơn 0, vui lòng nhập lại số tiền";
        } else if (amount > copy.getDocument().getPrice()) {
            outError = "Tiền phạt không được vượt quá giá tài liệu, vui lòng nhập lại số tiền";
        } else if (inReason.isEmpty()) {
            outError = "Lí do không được để trống, vui lòng nhập lí do";
        } else {
            // Đóng gói Fine2 hỏng hóc, đặt vào session và về trang quét tài liệu
            Fine2 fine = new Fine2();
            fine.setFineType(outFineType);
            fine.setAmount(amount);
            fine.setReason(inReason);
            session.setAttribute("fine", fine);
            response.sendRedirect(request.getContextPath() + "/view/librarian/ScanDocumentView2.jsp");
            return;
        }
    }

    // Chuẩn bị giá trị hiển thị
    String errorDisplay = "none";
    if (!outError.isEmpty()) {
        errorDisplay = "block";
    }
    String outCopyCode = copy.getCopyCode();
    String outTitle = copy.getDocument().getTitle();
    float outPrice = copy.getDocument().getPrice();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Bổ sung tiền phạt</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Nhân viên: " + librarian.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Bổ sung tiền phạt</h1>
        <form method="post">
            <input type="hidden" name="action" value="luu">
            <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:6px 20px;margin-bottom:16px;">
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã tài liệu cho mượn:</div><div id="outCopyCode"><%= esc(outCopyCode) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Tên tài liệu:</div><div id="outTitle"><%= esc(outTitle) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Giá tài liệu (đồng):</div><div id="outPrice"><%= money(outPrice) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Loại phạt:</div><div id="outFineType"><%= esc(outFineType) %></div></div>
            </div>
            <div style="display:flex;align-items:center;margin:14px 0;"><label for="inAmount" style="width:170px;font-weight:bold;">Số tiền:</label><input type="number" id="inAmount" name="inAmount" min="0" step="1" value="<%= esc(inAmount) %>" style="width:100%;max-width:520px;height:41px;padding:0 10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;"></div>
            <div style="display:flex;align-items:flex-start;margin:14px 0;"><label for="inReason" style="width:170px;font-weight:bold;padding-top:10px;">Lí do:</label><textarea id="inReason" name="inReason" style="width:100%;max-width:520px;height:90px;padding:10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;"><%= esc(inReason) %></textarea></div>
            <div id="outError" style="margin:16px 0;padding:10px 14px;background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;border-radius:6px;display:<%= errorDisplay %>;"><%= esc(outError) %></div>
            <button type="submit" id="btnSave" style="height:42px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Lưu</button>
        </form>
        <form method="post">
            <input type="hidden" name="action" value="quaylai">
            <button type="submit" id="btnBack" style="position:absolute;top:24px;right:24px;height:42px;padding:0 20px;background:#ffffff;color:#374151;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Quay lại</button>
        </form>
    </div>
</div>
</body>
</html>
