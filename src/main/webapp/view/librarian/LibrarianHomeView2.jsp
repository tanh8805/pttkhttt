<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.model.*" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang chủ nhân viên thư viện: hiển thị tên nhân viên và nút Nhận trả tài liệu
    // Lấy nhân viên đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Librarian2 librarian = (Librarian2) session.getAttribute("librarian");
    if (librarian == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }

    String outLibrarianName = "Xin chào, " + librarian.getFullName();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Trang chủ nhân viên thư viện</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Nhân viên: " + librarian.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Trang chủ nhân viên thư viện</h1>
        <p id="outLibrarianName" style="margin:0 0 20px 0;"><%= esc(outLibrarianName) %></p>
        <form method="post" action="<%= request.getContextPath() %>/view/librarian/FindReaderView2.jsp">
            <button type="submit" id="btnReturnDocument" style="height:46px;padding:0 28px;background:#1d4ed8;color:#ffffff;border:none;border-radius:8px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Nhận trả tài liệu</button>
        </form>
    </div>
</div>
</body>
</html>
