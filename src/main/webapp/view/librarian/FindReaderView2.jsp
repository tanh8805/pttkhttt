<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.dao.*, libman.model.*, java.util.Objects" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang quét thẻ bạn đọc: tìm bạn đọc theo mã thẻ rồi xác nhận để sang trang nhận trả
    // Lấy nhân viên đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Librarian2 librarian = (Librarian2) session.getAttribute("librarian");
    if (librarian == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }

    String action = request.getParameter("action");
    // Lấy bạn đọc đã quét từ session (nếu có)
    Reader2 reader = (Reader2) session.getAttribute("reader");
    String inCardCode = "";
    if (reader != null) {
        inCardCode = reader.getReaderCard().getCardCode();
    }
    String outError = "";

    if (action != null && action.equals("quaylai")) {
        // Bấm Quay lại: xoá dữ liệu nhận trả của phiên, về trang chủ nhân viên
        session.removeAttribute("reader");
        session.removeAttribute("listDetail");
        session.removeAttribute("listBorrowSlip");
        session.removeAttribute("borrowSlip");
        session.removeAttribute("fine");
        response.sendRedirect(request.getContextPath() + "/view/librarian/LibrarianHomeView2.jsp");
        return;
    } else if (action != null && action.equals("xacnhan")) {
        // Bấm Xác nhận: phải có bạn đọc đã quét, rồi sang trang nhận trả
        if (reader == null) {
            outError = "Vui lòng quét thẻ bạn đọc";
        } else {
            response.sendRedirect(request.getContextPath() + "/view/librarian/ReturnDocumentView2.jsp");
            return;
        }
    } else if (action != null && action.equals("tim")) {
        // Bấm Tìm: tìm bạn đọc theo mã thẻ, đặt vào session, xoá danh sách trả cũ
        inCardCode = Objects.toString(request.getParameter("inCardCode"), "").trim();
        ReaderDAO2 readerDAO = new ReaderDAO2();
        reader = readerDAO.getReaderByCardCode(inCardCode);
        session.removeAttribute("listDetail");
        session.removeAttribute("listBorrowSlip");
        session.removeAttribute("borrowSlip");
        session.removeAttribute("fine");
        if (reader == null) {
            session.removeAttribute("reader");
            outError = "Không tìm thấy bạn đọc, vui lòng quét lại thẻ";
        } else {
            session.setAttribute("reader", reader);
        }
    }

    // Chuẩn bị giá trị hiển thị
    String errorDisplay = "none";
    if (!outError.isEmpty()) {
        errorDisplay = "block";
    }
    String infoDisplay = "none";
    String outCardCode = "";
    String outFullName = "";
    String outStudentCode = "";
    String outExpiryDate = "";
    if (reader != null) {
        infoDisplay = "block";
        outCardCode = reader.getReaderCard().getCardCode();
        outFullName = reader.getFullName();
        outStudentCode = reader.getReaderCode();
        outExpiryDate = fmtDate(reader.getReaderCard().getExpiryDate());
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Quét thẻ bạn đọc</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Nhân viên: " + librarian.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Quét thẻ bạn đọc</h1>
        <form method="post">
            <input type="hidden" name="action" value="tim">
            <label for="inCardCode" style="display:block;margin-bottom:7px;font-weight:bold;">Mã thẻ:</label>
            <div style="display:flex;align-items:center;">
                <input type="text" id="inCardCode" name="inCardCode" value="<%= esc(inCardCode) %>" autofocus style="width:100%;max-width:440px;height:41px;padding:0 10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;">
                <button type="submit" id="btnFind" style="height:42px;margin-left:12px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Tìm</button>
            </div>
        </form>
        <div id="outError" style="margin:16px 0 0 0;padding:10px 14px;background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;border-radius:6px;display:<%= errorDisplay %>;"><%= esc(outError) %></div>
        <div style="display:<%= infoDisplay %>;">
            <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:6px 20px;margin:16px 0;">
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã thẻ:</div><div id="outCardCode"><%= esc(outCardCode) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Họ tên:</div><div id="outFullName"><%= esc(outFullName) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã sinh viên:</div><div id="outStudentCode"><%= esc(outStudentCode) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Ngày hết hạn thẻ:</div><div id="outExpiryDate"><%= esc(outExpiryDate) %></div></div>
            </div>
            <form method="post">
                <input type="hidden" name="action" value="xacnhan">
                <button type="submit" id="btnConfirm" style="height:42px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Xác nhận</button>
            </form>
        </div>
        <form method="post">
            <input type="hidden" name="action" value="quaylai">
            <button type="submit" id="btnBack" style="position:absolute;top:24px;right:24px;height:42px;padding:0 20px;background:#ffffff;color:#374151;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Quay lại</button>
        </form>
    </div>
</div>
</body>
</html>
