<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.dao.*, libman.model.*, java.time.LocalDate, java.util.Objects" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang đăng kí làm thẻ bạn đọc: nhập số điện thoại, địa chỉ, chọn ảnh rồi bấm Thêm
    // Lấy bạn đọc đăng nhập từ session, chưa đăng nhập thì về trang đăng nhập
    Reader2 reader = (Reader2) session.getAttribute("reader");
    if (reader == null) {
        response.sendRedirect(request.getContextPath() + "/view/member/LoginView2.jsp?err=timeout");
        return;
    }
    // Bạn đọc đã có thẻ thì về trang chủ
    if (reader.getReaderCard() != null) {
        response.sendRedirect(request.getContextPath() + "/view/reader/ReaderHomeView2.jsp");
        return;
    }

    // Loại thẻ theo đối tượng bạn đọc: sinh viên 12 tháng, còn lại 24 tháng
    String cardType = reader.getReaderType();
    int months = 24;
    if (cardType.equals("Sinh viên")) {
        months = 12;
    }
    String outCardType = cardType + " (thẻ " + cardType.toLowerCase() + " có thời hạn " + months + " tháng kể từ ngày cấp)";

    // Giá trị các ô nhập và thông báo lỗi ban đầu
    String inPhoneNumber = "";
    String inAddress = "";
    String outError = "";

    String action = request.getParameter("action");

    if (action != null && action.equals("quaylai")) {
        // Bấm Quay lại: về trang chủ bạn đọc
        response.sendRedirect(request.getContextPath() + "/view/reader/ReaderHomeView2.jsp");
        return;
    } else if (action != null && action.equals("them")) {
        // Bấm Thêm: kiểm tra dữ liệu nhập, lưu thông tin bạn đọc và thẻ
        inPhoneNumber = Objects.toString(request.getParameter("inPhoneNumber"), "").trim();
        inAddress = Objects.toString(request.getParameter("inAddress"), "").trim();
        String inPortrait = Objects.toString(request.getParameter("inPortrait"), "").trim();
        inPortrait = inPortrait.substring(Math.max(inPortrait.lastIndexOf('/'), inPortrait.lastIndexOf('\\')) + 1);

        if (!inPhoneNumber.matches("\\d{10}")) {
            outError = "Số điện thoại phải gồm đúng 10 chữ số, vui lòng nhập lại";
        } else if (inAddress.isEmpty()) {
            outError = "Địa chỉ không được để trống, vui lòng nhập địa chỉ";
        } else if (inPortrait.isEmpty()) {
            outError = "Chưa chọn ảnh chân dung, vui lòng chọn ảnh chân dung";
        } else if (!inPortrait.toLowerCase().matches(".*\\.(jpg|jpeg|png)")) {
            outError = "Ảnh chân dung phải là tệp JPG hoặc PNG, vui lòng chọn lại ảnh";
        } else {
            LocalDate today = LocalDate.now();

            // Đóng gói Reader2 có số điện thoại, địa chỉ mới rồi cập nhật bằng ReaderDAO2
            Reader2 updated = new Reader2();
            updated.setId(reader.getId());
            updated.setUsername(reader.getUsername());
            updated.setFullName(reader.getFullName());
            updated.setDateOfBirth(reader.getDateOfBirth());
            updated.setEmail(reader.getEmail());
            updated.setRole(reader.getRole());
            updated.setReaderCode(reader.getReaderCode());
            updated.setUnit(reader.getUnit());
            updated.setReaderType(reader.getReaderType());
            updated.setPhoneNumber(inPhoneNumber);
            updated.setAddress(inAddress);

            ReaderDAO2 readerDAO = new ReaderDAO2();
            if (!readerDAO.updateReader(updated)) {
                outError = "Lỗi lưu dữ liệu, không cập nhật được thông tin bạn đọc";
            } else {
                // Đóng gói ReaderCard2 (hạn thẻ tính từ hôm nay) rồi lưu bằng ReaderCardDAO2
                ReaderCard2 card = new ReaderCard2();
                card.setCardType(cardType);
                card.setPortraitImage(inPortrait);
                card.setIssueDate(java.sql.Date.valueOf(today));
                card.setExpiryDate(java.sql.Date.valueOf(today.plusMonths(months)));
                card.setStatus("Hoạt động");

                ReaderCardDAO2 cardDAO = new ReaderCardDAO2();
                if (!cardDAO.addReaderCard(updated, card)) {
                    outError = "Lỗi lưu dữ liệu, không lưu được thẻ bạn đọc";
                } else {
                    updated.setReaderCard(card);
                    // Lưu xong: đặt bạn đọc, thẻ vào session và sang trang kết quả
                    session.setAttribute("reader", updated);
                    session.setAttribute("card", card);
                    response.sendRedirect(request.getContextPath() + "/view/reader/RegisterCardResultView2.jsp");
                    return;
                }
            }
        }
    }

    // Chuẩn bị giá trị hiển thị
    String errorDisplay = "none";
    if (!outError.isEmpty()) {
        errorDisplay = "block";
    }
    String outFullName = reader.getFullName();
    String outDateOfBirth = fmtDate(reader.getDateOfBirth());
    String outStudentCode = reader.getReaderCode();
    String outUnit = reader.getUnit();
    String outEmail = reader.getEmail();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Đăng kí làm thẻ bạn đọc</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Bạn đọc: " + reader.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Đăng kí làm thẻ bạn đọc</h1>
        <form method="post">
            <input type="hidden" name="action" value="them">
            <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:6px 20px;margin-bottom:16px;">
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Họ tên:</div><div id="outFullName"><%= esc(outFullName) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Ngày sinh:</div><div id="outDateOfBirth"><%= esc(outDateOfBirth) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Mã sinh viên:</div><div id="outStudentCode"><%= esc(outStudentCode) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Đơn vị:</div><div id="outUnit"><%= esc(outUnit) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:170px;color:#6b7280;">Email:</div><div id="outEmail"><%= esc(outEmail) %></div></div>
            </div>
            <div style="display:flex;align-items:center;margin:14px 0;"><label for="inPhoneNumber" style="width:170px;font-weight:bold;">Số điện thoại:</label><input type="text" id="inPhoneNumber" name="inPhoneNumber" value="<%= esc(inPhoneNumber) %>" style="width:100%;max-width:520px;height:41px;padding:0 10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;"></div>
            <div style="display:flex;align-items:center;margin:14px 0;"><label for="inAddress" style="width:170px;font-weight:bold;">Địa chỉ:</label><input type="text" id="inAddress" name="inAddress" value="<%= esc(inAddress) %>" style="width:100%;max-width:520px;height:41px;padding:0 10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;"></div>
            <div style="display:flex;align-items:flex-start;margin:14px 0;">
                <div style="width:170px;font-weight:bold;">Loại thẻ:</div>
                <div id="outCardType"><%= esc(outCardType) %></div>
            </div>
            <div style="display:flex;align-items:center;margin:14px 0;">
                <div style="width:170px;font-weight:bold;">Ảnh chân dung:</div>
                <div style="display:flex;align-items:center;">
                    <button type="button" onclick="document.getElementById('inPortrait').click()" style="height:42px;padding:0 20px;background:#ffffff;color:#374151;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Chọn ảnh</button>
                    <span id="outPortraitFileName" style="margin-left:14px;color:#6b7280;">Chưa chọn tệp</span>
                    <input type="file" id="inPortrait" name="inPortrait" accept=".jpg,.jpeg,.png" style="display:none"
                           onchange="var n = document.getElementById('outPortraitFileName'); n.textContent = this.files.length ? this.files[0].name : 'Chưa chọn tệp'; n.style.color = this.files.length ? '#111827' : '#6b7280';">
                </div>
            </div>
            <div id="outError" style="margin:16px 0;padding:10px 14px;background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;border-radius:6px;display:<%= errorDisplay %>;"><%= esc(outError) %></div>
            <button type="submit" id="btnAdd" style="height:42px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Thêm</button>
        </form>
        <form method="post">
            <input type="hidden" name="action" value="quaylai">
            <button type="submit" id="btnBack" style="position:absolute;top:24px;right:24px;height:42px;padding:0 20px;background:#ffffff;color:#374151;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Quay lại</button>
        </form>
    </div>
</div>
</body>
</html>
