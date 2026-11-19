<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.dao.MemberDAO2, libman.model.*" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang đăng nhập: kiểm tra tài khoản bằng MemberDAO2, bạn đọc về trang chủ bạn đọc, nhân viên về trang chủ nhân viên
    String outError = "";
    if ("POST".equals(request.getMethod())) {
        // Bấm Đăng nhập: kiểm tra tài khoản, sai thì báo lỗi
        String username = request.getParameter("inUsername");
        String password = request.getParameter("inPassword");
        MemberDAO2 dao = new MemberDAO2();
        Member2 member = dao.checkLogin(username == null ? "" : username.trim(), password == null ? "" : password);
        if (member == null) {
            outError = "Sai tên đăng nhập hoặc mật khẩu";
        } else {
            // Đăng nhập đúng: tạo phiên mới, đặt người dùng vào session rồi sang trang chủ
            session.invalidate();
            session = request.getSession(true);
            if (member instanceof Reader2) {
                session.setAttribute("reader", member);
                response.sendRedirect(request.getContextPath() + "/view/reader/ReaderHomeView2.jsp");
            } else {
                session.setAttribute("librarian", member);
                response.sendRedirect(request.getContextPath() + "/view/librarian/LibrarianHomeView2.jsp");
            }
            return;
        }
    } else if ("timeout".equals(request.getParameter("err"))) {
        outError = "Phiên đăng nhập đã hết, vui lòng đăng nhập lại";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Đăng nhập</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("") %>
<div style="max-width:400px;margin:60px auto;padding:0 16px;">
    <div style="background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Đăng nhập</h1>
        <form method="post">
            <div style="margin-bottom:16px;">
                <label for="inUsername" style="display:block;margin-bottom:7px;font-weight:bold;">Tên đăng nhập:</label>
                <input type="text" id="inUsername" name="inUsername" style="width:100%;height:41px;padding:0 10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;">
            </div>
            <div style="margin-bottom:16px;">
                <label for="inPassword" style="display:block;margin-bottom:7px;font-weight:bold;">Mật khẩu:</label>
                <input type="password" id="inPassword" name="inPassword" style="width:100%;height:41px;padding:0 10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;">
            </div>
            <% if (!outError.isEmpty()) { %><div id="outError" style="margin:16px 0;padding:10px 14px;background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;border-radius:6px;"><%= esc(outError) %></div><% } %>
            <button type="submit" id="btnLogin" name="btnLogin" style="height:42px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Đăng nhập</button>
        </form>
    </div>
</div>
</body>
</html>
