CREATE DATABASE IF NOT EXISTS design_db;
USE design_db;

CREATE TABLE IF NOT EXISTS  Readers(
	reader_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(15) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS  Membership_Details(
	card_id VARCHAR(10) PRIMARY KEY,
    reader_id INT NOT NULL,
    card_rank ENUM('Standard', 'VIP') NOT NULL,
    expiry_date DATE NOT NULL,
    citizen_id VARCHAR(25) NOT NULL UNIQUE,
    
    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id)
);
CREATE TABLE IF NOT EXISTS  Categories(
	category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS  Books(
	book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL UNIQUE,
    author VARCHAR(150) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK(price > 0),
    stock_quantity INT NOT NULL CHECK(stock_quantity >= 0),
    
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE IF NOT EXISTS Loan_Records(
	loan_id INT PRIMARY KEY AUTO_INCREMENT,
    reader_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    
    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

DELIMITER //

CREATE TRIGGER chk_due_date
BEFORE INSERT ON Loan_Records
FOR EACH ROW
BEGIN
	IF (NEW.due_date < NEW.borrow_date) THEN 
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'NGÀY TRẢ PHẢI LỚN HƠN NGÀY MƯỢN';
    END IF;
END //

DELIMITER ;



-- 1.2 (15 Đ) INSERT
INSERT INTO Readers (reader_id, full_name, email, phone_number, created_at) VALUES
(1, 'Nguyen Van A', 'anv@gmail.com', '901234567','2022-01-15'),
(2, 'Tran Thi B', 'btt@gmail.com', '912345678','2022-05-20'),
(3, 'Le Van C', 'cle@yahoo.com','922334455', '2023-02-10'),
(4, 'Pham Minh D', 'dpham@hotmail.com', '933445566','2023-11-5'),
(5, 'Hoang Anh E', 'ehoang@gmail.com', '944556677','2023-01-12');

INSERT INTO Membership_Details(card_id, reader_id, card_rank, expiry_date, citizen_id) VALUES
('CARD-001', 1, 'Standard', '2025-01-15', '123456789'),
('CARD-002', 2, 'VIP', '2025-05-20', '234567890'),
('CARD-003', 3, 'Standard', '2024-02-10', '345678901'),
('CARD-004', 4, 'VIP', '2025-11-05', '456789012'),
('CARD-005', 5, 'Standard', '2026-01-12', '567890123');

INSERT INTO Categories(category_id, category_name, description) VALUES
(1, 'IT', 'Sách về công nghệ thông tin và lập trình'),
(2, 'Kinh Te', 'Sách kinh doanh, tài chính, khởi nghiệp'),
(3, 'Van Hoc', 'Tiểu thuyết, truyện ngắn, thơ'),
(4, 'Ngoai Ngu', 'Sách học Tiếng Anh, Nhật, Hàn'),
(5, 'Lich Su', 'Sách nghiên cứu lịch sử, văn hóa');

INSERT INTO Books(book_id, title, author, category_id, price, stock_quantity) VALUES
(1, 'Clean Code', 'Robert C Martin', 1, 450000, 10),
(2, 'Dac Nhan Tam', 'Dele Carnegie', 2, 150000, 50),
(3, 'Harry Potter 1', 'J.K Rowling', 3, 250000, 5),
(4, 'IELTS Reading', 'Cambridge', 4, 180000, 0),
(5, 'Dai Viet Su Ky', 'Le Van Huu', 5, 300000, 20);

INSERT INTO Loan_Records(loan_id, reader_id, book_id, borrow_date, due_date, return_date) VALUES 
(101, 1, 1,'2023-11-15', '2023-11-22', '2023-11-20'),
(102, 2, 2,'2023-12-01', '2023-12-08', '2023-12-05'),
(103, 1, 3,'2024-01-10', '2024-01-17', NULL),
(104, 3, 4,'2023-05-20', '2023-05-27', NULL),
(105, 4, 1,'2023-01-18', '2024-01-25', NULL);

DELETE FROM Loan_Records
WHERE YEAR(return_date) < 2023 
AND MONTH(return_date) < 10 
AND return_date <> NULL;

-- p2 (15 điểm )
-- câu 1 5 đ
SELECT b.book_id, b.title, b.price 
FROM Books b 
JOIN Categories cate ON b.category_id = cate.category_id
WHERE cate.category_name = 'IT' AND b.price > 200000;

-- câu 2 5 đ
SELECT reader_id, full_name, email 
FROM Readers 
WHERE YEAR(created_at) = 2022 AND email LIKE '%@gmail.com%';

-- câu 3 hiển thị 5 bỏ 2 (5 đ)
SELECT book_id, title, price
FROM Books
ORDER BY price DESC LIMIT 5 OFFSET 2;
 
 -- p3 (20 điểm)
 -- câu 1 6 đ 
 SELECT l.loan_id, r.full_name, b.title, l.borrow_date, l.due_date
 FROM Loan_Records l 
 JOIN Readers r ON l.reader_id = r.reader_id
 JOIN Books b ON l.book_id = b.book_id
 WHERE l.return_date IS NULL;
 
 -- câu 2 7 điểm
 SELECT cate.category_name, SUM(b.stock_quantity)
 FROM Books b
 JOIN Categories cate ON b.category_id = cate.category_id
 WHERE b.stock_quantity > 10 
 GROUP BY cate.category_name;
 
 -- Câu 3 7 điểm
 SELECT r.full_name
 FROM Loan_Records l 
 JOIN Readers r ON l.reader_id = r.reader_id
 JOIN Books b ON l.book_id = b.book_id
 JOIN Membership_Details md ON l.reader_id = md.reader_id
 WHERE md.card_rank = 'VIP' AND b.book_id IN (SELECT b2.book_id FROM Books b2 WHERE b2.price < 300000);
 
 -- P4 (10 điểm )
 -- Câu 1 5 đ
 CREATE INDEX idx_loan_dates 
 ON Loan_Records(borrow_date, return_date);
 
 -- câu 2 5 đ
 CREATE VIEW vw_overdue_loans AS
 SELECT l.loan_id, r.full_name, b.title, l.borrow_date, l.due_date
 FROM Loan_Records l 
 JOIN Readers r ON l.reader_id = r.reader_id
 JOIN Books b ON l.book_id = b.book_id
 WHERE l.return_date IS NULL;
 
 SELECT * FROM vw_overdue_loans;
 
 -- p5 TRIGGER(15 đ)
 -- câu 1 
 
 DELIMITER //
 
 CREATE TRIGGER trg_after_loan_insert 
 AFTER INSERT ON Loan_Records
 FOR EACH ROW
 BEGIN
	UPDATE Books
    SET stock_quantity = stock_quantity - 1 
    WHERE book_id = NEW.book_id;
 END //
 
 DELIMITER ;
 
 -- P6 15 đ
 -- câu 1 (7 đ)
DELIMITER //
 
CREATE PROCEDURE sp_check_availability (IN p_book_id INT, OUT p_message VARCHAR(50))
BEGIN
	DECLARE v_stock_quantity INT ;
    
    SELECT stock_quantity INTO v_stock_quantity
    FROM Books
    WHERE book_id = p_book_id;

	IF v_stock_quantity > 5 THEN
		SET p_message = 'Còn hàng';
	ELSEIF v_stock_quantity > 0 AND v_stock_quantity <= 5 THEN
		SET p_message = 'Sắp hết';
	ELSEIF v_stock_quantity = 0 THEN 
		SET p_message = 'Hết hàng';
	ELSE 
		SET p_message = 'Không có sách này';
	END IF;
	
END //
 
DELIMITER ;
 
 -- test
 CALL sp_check_availability(2, @mess);
 SELECT @mess;
 
 -- câu 2 (8 đ)

 
 DELIMITER //
 
CREATE PROCEDURE sp_return_book_transaction(IN p_loan_id INT)
BEGIN
	DECLARE v_return_date INT;
    DECLARE v_book_id INT;
    
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
	END;
    START TRANSACTION;
    
		SELECT book_id, return_date 
		INTO v_book_id, v_return_date
		FROM Loan_Records
		WHERE loan_id = p_loan_id;
		
		IF v_return_date <> NULL THEN 
			SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Sách đã trả rồi';
		ELSE
			UPDATE Loan_Records
			SET return_date = CURDATE()
			WHERE loan_id = p_loan_id;
			
			UPDATE Books
			SET stock_quantity = stock_quantity + 1 
			WHERE book_id = v_book_id;
			
		END IF;
    
    COMMIT;
END //
 
 DELIMITER ;
 
 -- test
 CALL sp_return_book_transaction(104); 
 