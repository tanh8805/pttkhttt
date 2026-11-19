<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="libman.dao.*, libman.model.*, java.time.LocalDate, java.time.temporal.ChronoUnit, java.util.Arrays, java.util.Objects" %>
<%@ include file="/WEB-INF/escape.jspf" %>
<%
    // Trang quét mã tài liệu: tìm phiếu mượn theo mã tài liệu, xem tiền phạt, xác nhận để thêm vào danh sách trả
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
    // Lấy danh sách dòng trả và danh sách phiếu mượn tương ứng
    ReturnReceiptDetail2[] listDetail = (ReturnReceiptDetail2[]) session.getAttribute("listDetail");
    BorrowSlip2[] listBorrowSlip = (BorrowSlip2[]) session.getAttribute("listBorrowSlip");
    if (listDetail == null || listBorrowSlip == null) {
        response.sendRedirect(request.getContextPath() + "/view/librarian/ReturnDocumentView2.jsp");
        return;
    }
    // Lấy phiếu mượn đang quét và khoản phạt hỏng hóc (nếu có) từ session
    BorrowSlip2 borrowSlip = (BorrowSlip2) session.getAttribute("borrowSlip");
    Fine2 fine = (Fine2) session.getAttribute("fine");

    String action = request.getParameter("action");
    String inCopyCode = "";
    if (borrowSlip != null) {
        inCopyCode = borrowSlip.getDetails()[0].getBorrowableDocument().getCopyCode();
    }
    String outError = "";

    if (action != null && action.equals("quaylai")) {
        // Bấm Quay lại: bỏ tài liệu đang quét, về trang nhận trả
        session.removeAttribute("borrowSlip");
        session.removeAttribute("fine");
        response.sendRedirect(request.getContextPath() + "/view/librarian/ReturnDocumentView2.jsp");
        return;
    } else if (action != null && action.equals("xacnhan")) {
        // Bấm Xác nhận: tạo khoản phạt trả chậm, tạo dòng trả, thêm vào danh sách trả
        if (borrowSlip == null) {
            outError = "Vui lòng quét mã tài liệu";
        } else {
            BorrowSlipDetail2 slipDetail = borrowSlip.getDetails()[0];
            // Số ngày quá hạn so với hôm nay, mỗi ngày phạt 5.000 đồng
            long lateDays = ChronoUnit.DAYS.between(new java.sql.Date(borrowSlip.getDueDate().getTime()).toLocalDate(), LocalDate.now());
            Fine2[] fines = new Fine2[0];
            if (lateDays > 0) {
                Fine2 lateFine = new Fine2();
                lateFine.setFineType("Trả chậm");
                lateFine.setAmount(lateDays * 5000f);
                lateFine.setReason("Quá hạn " + lateDays + " ngày");
                fines = Arrays.copyOf(fines, fines.length + 1);
                fines[fines.length - 1] = lateFine;
            }
            if (fine != null) {
                fines = Arrays.copyOf(fines, fines.length + 1);
                fines[fines.length - 1] = fine;
            }

            // Đóng gói dòng trả kèm các khoản phạt
            ReturnReceiptDetail2 detail = new ReturnReceiptDetail2();
            detail.setBorrowSlipDetail(slipDetail);
            detail.setBorrowableDocument(slipDetail.getBorrowableDocument());
            detail.setFines(fines);

            // Thêm dòng trả và phiếu mượn vào hai danh sách, xoá tài liệu đang quét, về trang nhận trả
            listDetail = Arrays.copyOf(listDetail, listDetail.length + 1);
            listDetail[listDetail.length - 1] = detail;
            listBorrowSlip = Arrays.copyOf(listBorrowSlip, listBorrowSlip.length + 1);
            listBorrowSlip[listBorrowSlip.length - 1] = borrowSlip;
            session.setAttribute("listDetail", listDetail);
            session.setAttribute("listBorrowSlip", listBorrowSlip);
            session.removeAttribute("borrowSlip");
            session.removeAttribute("fine");
            response.sendRedirect(request.getContextPath() + "/view/librarian/ReturnDocumentView2.jsp");
            return;
        }
    } else if (action != null && action.equals("tim")) {
        // Bấm Tìm: lấy phiếu mượn của tài liệu vừa quét
        inCopyCode = Objects.toString(request.getParameter("inCopyCode"), "").trim();
        borrowSlip = null;
        fine = null;
        session.removeAttribute("borrowSlip");
        session.removeAttribute("fine");
        // Tài liệu đã nằm trong danh sách trả thì báo đã quét
        boolean scanned = false;
        for (int i = 0; i < listDetail.length; i++) {
            if (listDetail[i].getBorrowableDocument().getCopyCode().equalsIgnoreCase(inCopyCode)) {
                scanned = true;
            }
        }
        if (scanned) {
            outError = "Tài liệu đã được quét, vui lòng quét tài liệu khác";
        } else {
            // Lấy phiếu mượn đang mượn của bạn đọc theo mã tài liệu
            BorrowSlipDAO2 borrowSlipDAO = new BorrowSlipDAO2();
            borrowSlip = borrowSlipDAO.getBorrowSlipByCopyCode(reader.getId(), inCopyCode);
            if (borrowSlip == null) {
                outError = "Tài liệu không có trong danh sách đang mượn, vui lòng quét lại";
            } else {
                session.setAttribute("borrowSlip", borrowSlip);
            }
        }
    }

    // Chuẩn bị giá trị hiển thị
    String errorDisplay = "none";
    if (!outError.isEmpty()) {
        errorDisplay = "block";
    }
    String infoDisplay = "none";
    String outCopyCode = "";
    String outTitle = "";
    String outBorrowCode = "";
    String outDueDate = "";
    float price = 0;
    float lateFineAmount = 0;
    float damageFineAmount = 0;
    if (fine != null) {
        damageFineAmount = fine.getAmount();
    }
    if (borrowSlip != null) {
        BorrowableDocument2 copy = borrowSlip.getDetails()[0].getBorrowableDocument();
        // Số ngày quá hạn so với hôm nay, mỗi ngày phạt 5.000 đồng
        long lateDays = ChronoUnit.DAYS.between(new java.sql.Date(borrowSlip.getDueDate().getTime()).toLocalDate(), LocalDate.now());
        infoDisplay = "block";
        outCopyCode = copy.getCopyCode();
        outTitle = copy.getDocument().getTitle();
        outBorrowCode = borrowSlip.getBorrowCode();
        outDueDate = fmtDate(borrowSlip.getDueDate());
        price = copy.getDocument().getPrice();
        if (lateDays > 0) {
            lateFineAmount = lateDays * 5000f;
        }
    }
    String lateColor = "#111827";
    if (lateFineAmount > 0) {
        lateColor = "#b91c1c";
    }
    String damageColor = "#111827";
    if (damageFineAmount > 0) {
        damageColor = "#b91c1c";
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>Quét mã tài liệu</title>
</head>
<body style="margin:0;background:#f3f4f6;font-family:Arial,Helvetica,sans-serif;font-size:15px;color:#111827;">
<%= topBar("Nhân viên: " + librarian.getFullName()) %>
<div style="max-width:1068px;margin:24px auto;padding:0 16px;">
    <div style="position:relative;background:#ffffff;border:1px solid #e5e7eb;border-radius:8px;padding:24px;box-shadow:0 1px 3px rgba(0,0,0,0.08);">
        <h1 style="margin:0 0 20px 0;font-size:22px;font-weight:bold;color:#111827;">Quét mã tài liệu</h1>
        <form method="post">
            <input type="hidden" name="action" value="tim">
            <label for="inCopyCode" style="display:block;margin-bottom:7px;font-weight:bold;">Mã tài liệu:</label>
            <div style="display:flex;align-items:center;">
                <input type="text" id="inCopyCode" name="inCopyCode" value="<%= esc(inCopyCode) %>" autofocus style="width:100%;max-width:440px;height:41px;padding:0 10px;border:1px solid #d1d5db;border-radius:6px;font-family:inherit;font-size:15px;box-sizing:border-box;">
                <button type="submit" id="btnFind" style="height:42px;margin-left:12px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Tìm</button>
            </div>
        </form>
        <div id="outError" style="margin:16px 0 0 0;padding:10px 14px;background:#fee2e2;color:#b91c1c;border:1px solid #fecaca;border-radius:6px;display:<%= errorDisplay %>;"><%= esc(outError) %></div>
        <div style="display:<%= infoDisplay %>;">
            <div style="background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;padding:6px 20px;margin:16px 0;">
                <div style="display:flex;margin:12px 0;"><div style="width:200px;color:#6b7280;">Mã tài liệu cho mượn:</div><div id="outCopyCode"><%= esc(outCopyCode) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:200px;color:#6b7280;">Tên tài liệu:</div><div id="outTitle"><%= esc(outTitle) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:200px;color:#6b7280;">Mã phiếu mượn:</div><div id="outBorrowCode"><%= esc(outBorrowCode) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:200px;color:#6b7280;">Ngày hẹn trả:</div><div id="outDueDate"><%= esc(outDueDate) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:200px;color:#6b7280;">Giá tài liệu (đồng):</div><div id="outPrice"><%= money(price) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:200px;color:#6b7280;">Phạt trả chậm (đồng):</div><div id="outLateFine" style="color:<%= lateColor %>;"><%= money(lateFineAmount) %></div></div>
                <div style="display:flex;margin:12px 0;"><div style="width:200px;color:#6b7280;">Phạt hỏng hóc (đồng):</div><div id="outDamageFine" style="color:<%= damageColor %>;"><%= money(damageFineAmount) %></div></div>
            </div>
            <form method="post" action="<%= request.getContextPath() %>/view/librarian/AddFineView2.jsp" style="display:inline;">
                <button type="submit" id="btnAddFine" style="height:42px;padding:0 22px;background:#ffffff;color:#1d4ed8;border:1px solid #1d4ed8;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Bổ sung tiền phạt</button>
            </form>
            <form method="post" style="display:inline;">
                <input type="hidden" name="action" value="xacnhan">
                <button type="submit" id="btnConfirm" style="height:42px;margin-left:8px;padding:0 22px;background:#1d4ed8;color:#ffffff;border:none;border-radius:6px;font-family:inherit;font-size:15px;font-weight:bold;cursor:pointer;box-sizing:border-box;">Xác nhận</button>
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
