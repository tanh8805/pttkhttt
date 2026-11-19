<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.model.*" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang chủ bạn đọc: hiển thị tên bạn đọc và nút Đăng kí làm thẻ bạn đọc
    // Lấy bạn đọc đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Reader2 reader = (Reader2) session.getAttribute("reader");
    if (reader == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }

    // Bấm Đăng kí làm thẻ bạn đọc: đã có thẻ thì báo, chưa có thì sang trang đăng kí
    String action = request.getParameter("action");
    String notice = "";

    if (action != null && action.equals("dangki")) {
        if (reader.getReaderCard() != null) {
            notice = "Bạn đã có thẻ bạn đọc, mã thẻ " + reader.getReaderCard().getCardCode()
                    + ", hạn thẻ " + fmtDate(reader.getReaderCard().getExpiryDate());
        } else {
            response.sendRedirect(request.getContextPath() + "/view/reader/RegisterCardView2.jsp");
            return;
        }
    }

    // Chuẩn bị giá trị hiển thị
    String noticeDisplay = "none";
    if (!notice.isEmpty()) {
        noticeDisplay = "block";
    }
    String outReaderName = "Xin chào, " + reader.getFullName();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Trang chủ bạn đọc</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Bạn đọc: " + reader.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Trang chủ bạn đọc</h1>
        <p id="outReaderName" style="margin:0 0 20px 0;"><%= esc(outReaderName) %></p>
        <div style="margin:0 0 16px 0;padding:10px 14px;background:#e0f2fe;color:#075985;border:1px solid #bae6fd;border-radius:6px;display:<%= noticeDisplay %>;"><%= esc(notice) %></div>
        <form method="post">
            <input type="hidden" name="action" value="dangki">
            <button type="submit" id="btnRegisterCard" style="height:46px;padding:0 28px;background:#1d4ed8;color:#ffffff;border:none;border-radius:8px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Đăng kí làm thẻ bạn đọc</button>
        </form>
    </div>
</div>
</body>
</html>
