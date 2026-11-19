-- Chạy: mysql -uroot -p < schema.sql
DROP DATABASE IF EXISTS libman;
CREATE DATABASE libman CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE libman;

CREATE TABLE tblMember2 (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(50)  NOT NULL UNIQUE,
    password    VARCHAR(100) NOT NULL,
    fullName    VARCHAR(100) NOT NULL,
    dateOfBirth DATE         NULL,
    address     VARCHAR(255) NULL,
    email       VARCHAR(100) NOT NULL,
    phoneNumber VARCHAR(20)  NULL,
    role        VARCHAR(20)  NOT NULL
);

CREATE TABLE tblReader2 (
    id         INT PRIMARY KEY,
    readerCode VARCHAR(20)  NOT NULL UNIQUE,
    unit       VARCHAR(100) NULL,
    readerType VARCHAR(20)  NOT NULL,
    FOREIGN KEY (id) REFERENCES tblMember2(id)
);

CREATE TABLE tblEmployee2 (
    id       INT PRIMARY KEY,
    position VARCHAR(50) NOT NULL,
    FOREIGN KEY (id) REFERENCES tblMember2(id)
);

CREATE TABLE tblReaderCard2 (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    cardCode      VARCHAR(20)  NOT NULL UNIQUE,
    cardType      VARCHAR(30)  NOT NULL,
    portraitImage VARCHAR(255) NOT NULL,
    issueDate     DATE         NOT NULL,
    expiryDate    DATE         NOT NULL,
    status        VARCHAR(20)  NOT NULL,
    tblReader2id  INT          NOT NULL UNIQUE,
    FOREIGN KEY (tblReader2id) REFERENCES tblReader2(id)
);

CREATE TABLE tblDocument2 (
    id           INT AUTO_INCREMENT PRIMARY KEY,
    documentCode VARCHAR(20)   NOT NULL UNIQUE,
    title        VARCHAR(200)  NOT NULL,
    documentType VARCHAR(30)   NOT NULL,
    author       VARCHAR(100)  NULL,
    publisher    VARCHAR(100)  NULL,
    publishYear  INT           NULL,
    price        DECIMAL(12,2) NOT NULL,
    coverImage   VARCHAR(255)  NULL,
    description  TEXT          NULL
);

CREATE TABLE tblOriginalDocument2 (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    originalCode  VARCHAR(20)  NOT NULL UNIQUE,
    location      VARCHAR(100) NOT NULL,
    tblDocument2id INT         NOT NULL UNIQUE,
    FOREIGN KEY (tblDocument2id) REFERENCES tblDocument2(id)
);

CREATE TABLE tblBorrowableDocument2 (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    copyCode       VARCHAR(20)  NOT NULL UNIQUE,
    location       VARCHAR(100) NULL,
    status         VARCHAR(20)  NOT NULL,
    tblDocument2id INT          NOT NULL,
    FOREIGN KEY (tblDocument2id) REFERENCES tblDocument2(id)
);

CREATE TABLE tblSupplier2 (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    taxCode     VARCHAR(20)  NULL,
    address     VARCHAR(255) NULL,
    phoneNumber VARCHAR(20)  NULL,
    email       VARCHAR(100) NULL,
    description TEXT         NULL
);

CREATE TABLE tblImportSlip2 (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    importCode     VARCHAR(20)  NOT NULL UNIQUE,
    importDate     DATE         NOT NULL,
    note           VARCHAR(255) NULL,
    tblSupplier2id INT          NOT NULL,
    tblEmployee2id INT          NOT NULL,
    FOREIGN KEY (tblSupplier2id) REFERENCES tblSupplier2(id),
    FOREIGN KEY (tblEmployee2id) REFERENCES tblEmployee2(id)
);

CREATE TABLE tblImportSlipDetail2 (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    quantity        INT           NOT NULL,
    unitPrice       DECIMAL(12,2) NOT NULL,
    tblImportSlip2id INT          NOT NULL,
    tblDocument2id  INT           NOT NULL,
    FOREIGN KEY (tblImportSlip2id) REFERENCES tblImportSlip2(id),
    FOREIGN KEY (tblDocument2id) REFERENCES tblDocument2(id)
);

CREATE TABLE tblBorrowSlip2 (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    borrowCode     VARCHAR(20) NOT NULL UNIQUE,
    borrowDate     DATE        NOT NULL,
    dueDate        DATE        NOT NULL,
    tblReader2id   INT         NOT NULL,
    tblEmployee2id INT         NOT NULL,
    FOREIGN KEY (tblReader2id) REFERENCES tblReader2(id),
    FOREIGN KEY (tblEmployee2id) REFERENCES tblEmployee2(id)
);

CREATE TABLE tblBorrowSlipDetail2 (
    id                       INT AUTO_INCREMENT PRIMARY KEY,
    tblBorrowSlip2id         INT NOT NULL,
    tblBorrowableDocument2id INT NOT NULL,
    FOREIGN KEY (tblBorrowSlip2id) REFERENCES tblBorrowSlip2(id),
    FOREIGN KEY (tblBorrowableDocument2id) REFERENCES tblBorrowableDocument2(id)
);

CREATE TABLE tblReturnReceipt2 (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    returnCode     VARCHAR(20) NOT NULL UNIQUE,
    returnDate     DATE        NOT NULL,
    tblReader2id   INT         NOT NULL,
    tblEmployee2id INT         NOT NULL,
    FOREIGN KEY (tblReader2id) REFERENCES tblReader2(id),
    FOREIGN KEY (tblEmployee2id) REFERENCES tblEmployee2(id)
);

CREATE TABLE tblReturnReceiptDetail2 (
    id                     INT AUTO_INCREMENT PRIMARY KEY,
    tblReturnReceipt2id    INT NOT NULL,
    tblBorrowSlipDetail2id INT NOT NULL UNIQUE,
    tblBorrowableDocument2id INT NOT NULL,
    FOREIGN KEY (tblReturnReceipt2id) REFERENCES tblReturnReceipt2(id),
    FOREIGN KEY (tblBorrowSlipDetail2id) REFERENCES tblBorrowSlipDetail2(id),
    FOREIGN KEY (tblBorrowableDocument2id) REFERENCES tblBorrowableDocument2(id)
);

CREATE TABLE tblFine2 (
    id                        INT AUTO_INCREMENT PRIMARY KEY,
    fineType                  VARCHAR(30)   NOT NULL,
    amount                    DECIMAL(12,2) NOT NULL,
    reason                    VARCHAR(255)  NULL,
    tblReturnReceiptDetail2id INT           NOT NULL,
    FOREIGN KEY (tblReturnReceiptDetail2id) REFERENCES tblReturnReceiptDetail2(id)
);

-- Tài khoản demo (mật khẩu đều là 123456): nhân viên tranthib; bạn đọc b23dccn001 (Nguyễn Văn A, có thẻ TH01234), b23dccn002 (Lê Văn C, có thẻ TH01233), b23dccn003 (Nguyễn Văn C) và b23dccn004 (Nguyễn Văn D) chưa có thẻ
INSERT INTO tblMember2 (id, username, password, fullName, dateOfBirth, address, email, phoneNumber, role) VALUES
(1, 'b23dccn001', '123456', 'Nguyễn Văn A', '2005-03-15', NULL, 'b23dccn001@stu.ptit.edu.vn', NULL, 'Reader'),
(2, 'tranthib',   '123456', 'Trần Thị B',    '1990-06-20', '12 Nguyễn Trãi, Hà Đông, Hà Nội', 'tranthib@ptit.edu.vn', '0912345678', 'Librarian'),
(3, 'b23dccn002', '123456', 'Lê Văn C',      '2005-07-20', '5 Lê Lợi, Hà Đông, Hà Nội', 'b23dccn002@stu.ptit.edu.vn', '0987654321', 'Reader'),
(4, 'b23dccn003', '123456', 'Nguyễn Văn C',  '2005-09-10', NULL, 'b23dccn003@stu.ptit.edu.vn', NULL, 'Reader'),
(5, 'b23dccn004', '123456', 'Nguyễn Văn D',  '2005-11-02', NULL, 'b23dccn004@stu.ptit.edu.vn', NULL, 'Reader');

INSERT INTO tblReader2 (id, readerCode, unit, readerType) VALUES
(1, 'B23DCCN001', 'Lớp D23CQCN01-B, Khoa Công nghệ thông tin 1', 'Sinh viên'),
(3, 'B23DCCN002', 'Lớp D23CQCN01-B, Khoa Công nghệ thông tin 1', 'Sinh viên'),
(4, 'B23DCCN003', 'Lớp D23CQCN01-B, Khoa Công nghệ thông tin 1', 'Sinh viên'),
(5, 'B23DCCN004', 'Lớp D23CQCN01-B, Khoa Công nghệ thông tin 1', 'Sinh viên');

INSERT INTO tblEmployee2 (id, position) VALUES (2, 'Thủ thư');

INSERT INTO tblReaderCard2 (id, cardCode, cardType, portraitImage, issueDate, expiryDate, status, tblReader2id) VALUES
(1, 'TH01233', 'Sinh viên', 'anh_the_C.jpg', DATE_SUB(CURDATE(), INTERVAL 9 MONTH), DATE_ADD(CURDATE(), INTERVAL 3 MONTH), 'Hoạt động', 3),
(2, 'TH01234', 'Sinh viên', 'anh_the_A.jpg', '2026-08-25', '2027-08-25', 'Hoạt động', 1);

INSERT INTO tblDocument2 (id, documentCode, title, documentType, author, publisher, publishYear, price) VALUES
(1, 'TL0012', 'Lập trình hướng đối tượng', 'Giáo trình', 'Nguyễn Văn Hiệu', 'NXB Thông tin và Truyền thông', 2020, 95000),
(2, 'TL0027', 'Cơ sở dữ liệu',              'Giáo trình', 'Trần Thị Mai',    'NXB Giáo dục Việt Nam',          2019, 80000),
(3, 'TL0104', 'Mạng máy tính',              'Giáo trình', 'Lê Quang Minh',   'NXB Đại học Quốc gia Hà Nội',    2021, 90000);

INSERT INTO tblOriginalDocument2 (originalCode, location, tblDocument2id) VALUES
('TL0012-00', 'Phòng đọc, kệ A1', 1),
('TL0027-00', 'Phòng đọc, kệ A2', 2),
('TL0104-00', 'Phòng đọc, kệ B1', 3);

INSERT INTO tblBorrowableDocument2 (id, copyCode, location, status, tblDocument2id) VALUES
(1, 'TL0012-01', 'Kệ A1', 'Trong kho', 1),
(2, 'TL0012-02', 'Kệ A1', 'Trong kho', 1),
(3, 'TL0012-03', 'Kệ A1', 'Đang mượn', 1),
(4, 'TL0027-01', 'Kệ A2', 'Trong kho', 2),
(5, 'TL0027-05', 'Kệ A2', 'Đang mượn', 2),
(6, 'TL0104-01', 'Kệ B1', 'Trong kho', 3),
(7, 'TL0104-02', 'Kệ B1', 'Đang mượn', 3);

INSERT INTO tblBorrowSlip2 (id, borrowCode, borrowDate, dueDate, tblReader2id, tblEmployee2id) VALUES
(1, 'PM00097', DATE_SUB(CURDATE(), INTERVAL 112 DAY), DATE_SUB(CURDATE(), INTERVAL 96 DAY), 3, 2),
(2, 'PM00098', DATE_SUB(CURDATE(), INTERVAL 17 DAY),  DATE_SUB(CURDATE(), INTERVAL 3 DAY),  1, 2),
(3, 'PM00105', DATE_SUB(CURDATE(), INTERVAL 3 DAY),   DATE_ADD(CURDATE(), INTERVAL 11 DAY), 1, 2),
(4, 'PM00111', DATE_SUB(CURDATE(), INTERVAL 64 DAY),  DATE_SUB(CURDATE(), INTERVAL 34 DAY), 1, 2);

INSERT INTO tblBorrowSlipDetail2 (id, tblBorrowSlip2id, tblBorrowableDocument2id) VALUES
(1, 1, 2),
(2, 2, 3),
(3, 3, 5),
(4, 4, 7);

INSERT INTO tblReturnReceipt2 (id, returnCode, returnDate, tblReader2id, tblEmployee2id) VALUES
(1, 'PT00017', DATE_SUB(CURDATE(), INTERVAL 97 DAY), 3, 2);
INSERT INTO tblReturnReceiptDetail2 (id, tblReturnReceipt2id, tblBorrowSlipDetail2id, tblBorrowableDocument2id) VALUES
(1, 1, 1, 2);
