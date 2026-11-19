<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.model.*" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang báo đăng kí thẻ bạn đọc thành công: hiển thị thông tin thẻ vừa tạo
    // Lấy bạn đọc đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Reader2 reader = (Reader2) session.getAttribute("reader");
    if (reader == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }
    // Lấy thẻ vừa tạo từ session
    ReaderCard2 card = (ReaderCard2) session.getAttribute("card");

    String action = request.getParameter("action");

    if (action != null && action.equals("ok")) {
        // Bấm OK: xoá thẻ khỏi session, về trang chủ bạn đọc
        session.removeAttribute("card");
        response.sendRedirect(request.getContextPath() + "/view/reader/ReaderHomeView2.jsp");
        return;
    }
    // Không có thẻ thì về trang chủ bạn đọc
    if (card == null) {
        response.sendRedirect(request.getContextPath() + "/view/reader/ReaderHomeView2.jsp");
        return;
    }

    // Chuẩn bị giá trị hiển thị
    String outCardCode = card.getCardCode();
    String outCardType = card.getCardType();
    String outFullName = reader.getFullName();
    String outStudentCode = reader.getReaderCode();
    String outIssueDate = fmtDate(card.getIssueDate());
    String outExpiryDate = fmtDate(card.getExpiryDate());
    String outStatus = card.getStatus();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Đăng kí thẻ bạn đọc thành công</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Bạn đọc: " + reader.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;"><span style="color:#16a34a;">&#10003;</span> Đăng kí thẻ bạn đọc thành công</h1>
        <div style="max-width:640px;border:1px solid #d1d5db;border-radius:8px;padding:12px 24px;margin-bottom:16px;">
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Mã thẻ:</div><div id="outCardCode"><%= esc(outCardCode) %></div></div>
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Loại thẻ:</div><div id="outCardType"><%= esc(outCardType) %></div></div>
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Họ tên:</div><div id="outFullName"><%= esc(outFullName) %></div></div>
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Mã sinh viên:</div><div id="outStudentCode"><%= esc(outStudentCode) %></div></div>
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Ngày cấp:</div><div id="outIssueDate"><%= esc(outIssueDate) %></div></div>
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Ngày hết hạn:</div><div id="outExpiryDate"><%= esc(outExpiryDate) %></div></div>
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Trạng thái:</div><div id="outStatus"><%= esc(outStatus) %></div></div>
            <div style="display:flex;margin:10px 0;"><div style="width:170px;color:#6b7280;">Ảnh chân dung:</div><div><%= esc(card.getPortraitImage()) %></div></div>
        </div>
        <form method="post">
            <input type="hidden" name="action" value="ok">
            <button type="submit" id="btnOK" style="height:42px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">OK</button>
        </form>
    </div>
</div>
</body>
</html>
