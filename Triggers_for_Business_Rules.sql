use library;

# BR1. Any book can be borrowed if and only if at least one copy of the book is being holding at the branch. 
select * from holding;

DELIMITER //
DROP TRIGGER IF EXISTS br1;

//
CREATE TRIGGER br1
  BEFORE INSERT ON Borrowedby
  FOR EACH ROW 
  BEGIN
    DECLARE msg VARCHAR(255);
    DECLARE v_stock INT DEFAULT 0;

    
    SET v_stock = (SELECT InStock - OnLoan
                   FROM Holding
                   WHERE BranchID = NEW.BranchID AND BookID = NEW.BookID);

    
    IF v_stock <= 0 THEN
      SET msg = "Book is out of stock";
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
  END;
//
DELIMITER ;

/*To test the trigger created for BR1 I have inserted data into holding table 
where OnStock and OnLoan vlaues are same, which means the books in branch books borrowed are same i.e., 0 books in stock*/
insert into holding values('1','4','2','2');
 select * from holding;           
/* when I try to insert row in borrowedby table with BranchID=1 and BookID=4, 
trigger will be activated as Book is out of stock*/
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('1', '4','2','2022-05-01',NULL,'2022-05-10');      



# BR2. Only members with “REGULAR” member status can borrow books.

select * from member;
select * from Borrowedby;
DELIMITER //
DROP TRIGGER IF EXISTS br2;
//
CREATE TRIGGER br2
  BEFORE INSERT ON Borrowedby
  FOR EACH ROW
  BEGIN
    DECLARE msg VARCHAR(255);
    DECLARE v_status VARCHAR(50);
    
    SELECT MemberStatus INTO v_status
    FROM Member
    WHERE Member.MemberID = NEW.MemberID;

    IF v_status <> "REGULAR" THEN
      SET msg = "This member cannot borrow a book";
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
  END;
//
DELIMITER ;


select MemberID,MemberStatus from Member where MemberStatus != "REGULAR";
/*To test the trigger created for BR2 I tried inserting a row in Borrowedby with MemberID=6
 whose Mmber status is SUSPENDED, trigger will be activated with message: This memeber cannot borrow a book.*/
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '5','6','2020-01-01',NULL,'2020-02-01');

# BR3. Each member can borrow one copy of the same book on the same day 

DELIMITER //
DROP TRIGGER IF EXISTS br3;
//
CREATE TRIGGER br3
  BEFORE INSERT ON Borrowedby
  FOR EACH ROW
  BEGIN
    DECLARE msg VARCHAR(255);
    DECLARE v_count INT;
    SELECT COUNT(*) INTO v_count
    FROM Borrowedby
    WHERE MemberID = NEW.MemberID
      AND BookID = NEW.BookID
      AND DateBorrowed = NEW.DateBorrowed;

    IF v_count > 0 THEN
      SET msg = "This member cannot borrow the same book on the same day";
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END IF;
    
  END;
//
DELIMITER ;



select * from Borrowedby;
/*To test the trigger created for BR3 I tried inserting a row in Borrowedby with values
 BookID=2, MemberID=2 and Date=2020-08-30, this book has already been borrowed by same member on same day,
 trigger will be activated with message: This memeber cannot borrow the same book on same day.*/
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('1', '2','2','2020-08-30',NULL,'2020-09-30');

# BR4. A member can borrow up to 5 items for 3 weeks (i.e., 21 days).
DROP TRIGGER IF EXISTS br4;
DELIMITER //
//
CREATE TRIGGER br4
  BEFORE INSERT ON Borrowedby
  FOR EACH ROW
  BEGIN
    DECLARE msg VARCHAR(255);
    DECLARE v_count INT;
    DECLARE v_date DATE;
    DECLARE days_difference INT;
    DECLARE days date;
    
    
    
    SELECT MIN(DateBorrowed) INTO v_date
    FROM Borrowedby
    WHERE MemberID = NEW.MemberID;
	
    IF v_date IS NOT NULL THEN
      set days = DATE_ADD(v_date, INTERVAL 21 DAY);
      if NEW.DateBorrowed < days then
      
		SELECT COUNT(*) INTO v_count
		FROM Borrowedby
		WHERE MemberID = NEW.MemberID
		AND DateBorrowed BETWEEN v_date AND DATE_ADD(v_date, INTERVAL 21 DAY);

		IF v_count >= 5 then
			SET msg = "This member has reached the maximum limit of 5 items within 21 days";
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
      END IF;
    END IF;
   End if;
  END;
//
DELIMITER ;

#to test trigger for BR4 first i have inserted values in holding table
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('3', '1','7','1');
# Now i started inserting 5 rows in borrowedby table with memberID=4

INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '1','5','2020-01-01',NULL,'2020-01-30');
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '1','5','2020-01-03',NULL,'2020-01-30');
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '1','5','2020-01-05',NULL,'2020-01-30');
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '1','5','2020-01-07',NULL,'2020-01-30');
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '1','5','2020-01-09',NULL,'2020-01-30');

/*when i try to insert 5th row in Borrwedby table with same memberId=5 and date less then 21 days from the earliest date book
borrowed, triger is activated with message This member has reached the maximum limit of 5 items within 21 days*/
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '1','5','2020-01-11',NULL,'2020-01-30');


# BR5. The return due date of the borrowed book cannot be past the membership expiry date.

DELIMITER //
DROP TRIGGER IF EXISTS br5;
//
CREATE TRIGGER br5
  BEFORE INSERT ON Borrowedby
  FOR EACH ROW
  BEGIN
    DECLARE msg VARCHAR(255);
    DECLARE v_date DATE;
       
    SELECT MemberExpDate INTO v_date
    FROM Member
    WHERE MemberID = NEW.MemberID;
    
    IF New.ReturnDueDate > v_date  then
        SET msg = "The due date for returning the borrowed book has exceeded the expiration date of the membership.";
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
      
    END IF;
  END;
//
DELIMITER ;

# BR 5
/* to  with test trigger for BR5 I tried to insert a row in borrowedby table for memberId=1
with return date '2021-10-10' which exceeds the members expiry date '2021-09-30'
trigger will be activated with message:
 The due date for returning the borrowed book has exceeded the expiration date of the membership. */ 
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('1', '3','1','2020-10-11',NULL,'2021-10-10');


# BR6. If a member has an outstanding fee* and it has reached $30, his/her membership will be suspended.
DELIMITER //
DROP TRIGGER IF EXISTS br6;
//

CREATE TRIGGER br6
  BEFORE UPDATE ON Member
  FOR EACH ROW
  BEGIN
       
    IF NEW.FineFee < 30 THEN
      SET NEW.MemberStatus = "REGULAR";
      SET @action = 'update';
	else
      SET NEW.MemberStatus = "SUSPENDED";
      SET @action = 'update';
    END IF;
  END;
//
DELIMITER ;
select * from member;

# BR 6 
/* To test error handler for BR6*/
select * from member;
/* MemberId=2 has status RGULAR and FineFee 0, i will add finefee of 45*/

update member
set FineFee= FineFee+45
where MemberID = 2;
/* the member status has been updated to SUSPENDED*/
select * from member;

/*if i fine less then 30*/
update member
set FineFee= 10
where MemberID = 2;
/*Member status is uodated to REGULAR*/
select * from member;

/* BR7. If a member has an overdue item, his/her fine fee will be increased $2/day passing the expiration date and 
 the membership will be suspended.*/
DELIMITER //
DROP TRIGGER IF EXISTS br7;
//
CREATE TRIGGER br7
BEFORE UPDATE ON Borrowedby
FOR EACH ROW
BEGIN
    DECLARE v_due_date DATE;
    DECLARE v_returned_date DATE;
    DECLARE v_overdue_days INT;
    DECLARE v_fine_amount DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_days INT;
    DECLARE v_member_exp_date DATE; 
   
    SET v_due_date = NEW.ReturnDueDate;
    SET v_returned_date = NEW.DateReturned;
    
    
    SELECT MemberExpDate INTO v_member_exp_date FROM Member WHERE MemberID = NEW.MemberID;
    
    
    SET v_days = DATEDIFF(v_member_exp_date, NEW.ReturnDueDate);

    
    IF v_returned_date IS NOT NULL THEN
        SET v_overdue_days = DATEDIFF(v_returned_date, v_due_date);
    ELSE
        SET v_overdue_days = DATEDIFF(CURDATE(), v_due_date);
    END IF;

   if v_overdue_days > 0 then
    SET v_fine_amount = v_overdue_days * 2;
    
   end if;
   
    UPDATE Member
    SET FineFee = FineFee + v_fine_amount
    WHERE MemberID = NEW.MemberID;
    
    
    IF  v_days < v_overdue_days THEN
        UPDATE Member
        SET MemberStatus = 'SUSPENDED'
        WHERE MemberID = NEW.MemberID;
	END IF;
END;
//
DELIMITER ;

select * from member;
select * from Borrowedby;
desc  borrowedby;
INSERT INTO Borrowedby 
VALUES (11, 1, 2, 3, '2019-12-20', NULL, '2020-02-29');

select * from branch;
Select * from book;
select * from holding;
/* to test trigger for BR7 i will first update the boorowedby row with BookIssueID = 11 and MemberID=5
here the member has returned the book before due date and befor his membership expiration date*/
UPDATE Borrowedby
SET DateReturned = '2020-01-10'
WHERE BookIssueID = 11 and MemberID=3;

select * from member;

/*member table is not updated with fine and member status
 because the member has returned the book before due date and befor his membership expiration date*/
 
 /*now i will update the boorowedby row with BookIssueID = 12 and MemberID=5
here the member has not returned the book before due date but returned before his membership expiration date**/
 UPDATE Borrowedby
SET DateReturned = '2020-03-10'
WHERE BookIssueID = 11 and MemberID=3;
 
 /*member table is  updated with fine
 because the member has not returned the book before due date*/
select * from member;
 /*now i will update the boorowedby row with BookIssueID = 13 and MemberID=5
here the member has not returned the book before due date and not returned before his membership expiration date**/
 UPDATE Borrowedby
SET DateReturned = '2021-10-01'
WHERE BookIssueID = 11 and MemberID=3;
 
 /*member table is  updated with fine fee and member status
 because the member has not returned the book before due date and expiration date of membership*/
select * from member;



/*BR8. When a suspended member clears their fine (i.e, paid all the outstanding fees) and has no or has
 returned all overdue items, reset the member’s membership status to “REGULAR”. */
DELIMITER //
DROP TRIGGER IF EXISTS br8_borrowedby;
//
CREATE TRIGGER br8_borrowedby
AFTER UPDATE ON Borrowedby
FOR EACH ROW
BEGIN
	DECLARE v_total_fine DECIMAL(10, 2);
    DECLARE v_overdue_items INT;
    DECLARE v_status varchar(50);
	SELECT MemberStatus  INTO v_status
    FROM Member 
    WHERE MemberID = NEW.MemberID;
  IF v_status = 'SUSPENDED' THEN     
    SELECT SUM(FineFee) INTO v_total_fine
    FROM Member
    WHERE MemberID = NEW.MemberID;    
    SELECT COUNT(*) INTO v_overdue_items
    FROM Borrowedby
    WHERE MemberID = NEW.MemberID AND DateReturned IS NULL;
  END IF;
    IF v_total_fine = 0 AND v_overdue_items = 0 THEN      
      UPDATE Member
      SET MemberStatus = 'REGULAR'
      WHERE MemberID = NEW.MemberID;
   END IF;
END;
//
DELIMITER ;

DELIMITER //
DROP TRIGGER IF EXISTS br8_member_fine;
//
CREATE TRIGGER br8_member_fine
AFTER UPDATE ON Member
FOR EACH ROW
BEGIN 
	DECLARE v_total_fine DECIMAL(10, 2);
    DECLARE v_overdue_items INT;
    DECLARE v_status varchar(50);
	SELECT MemberStatus  INTO v_status
    FROM Member 
    WHERE MemberID = NEW.MemberID;
  IF v_status = 'SUSPENDED' THEN     
    SELECT SUM(FineFee) INTO v_total_fine
    FROM Member
    WHERE MemberID = NEW.MemberID;    
    SELECT COUNT(*) INTO v_overdue_items
    FROM Borrowedby
    WHERE MemberID = NEW.MemberID AND DateReturned IS NULL;
  END IF;
    IF v_total_fine = 0 AND v_overdue_items = 0 THEN      
      UPDATE Member
      SET MemberStatus = 'REGULAR'
      WHERE MemberID = NEW.MemberID;
   END IF;
END;
//
DELIMITER ;

/*To test Task 2 I will insert a new member in table Member with MemberStatus as SUSPENDED and FineFee as 50*/
INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone,FineFee) 
VALUES ('7','SUSPENDED','Fayyaz','8 Mark St','Lidcombe','NSW','2023-08-20','0434567541',50);
select * from member;

/*Now I will insert a data into borrowedby table for MemberID=7 with DateReturned will be null*/
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '4','7','2023-01-01',NULL,'2023-02-01');
/*Now i will update the borrowedby table and add the date returned to previously added record*/
update Borrowedby
set Datereturned = '2023-01-20'
where BookIssueID=9;
select * from borrowedby;
select * from member;
/*the memberID 7 has returned the book but still his member status is suspended 
because he is having fine fee, if member pays the fine fee the his status will be set to regular*/
update Member
set FineFee=0
where MemberID = 7;
select * from Member;

/*Write a stored procedure to list the members that currently have an overdue item and their (individual) 
membership has been suspended twice in the past three years. End these members’ membership by settng their 
MemberStatus to “TERMINATED”. Error handler must be implemented to handle excepMons.*/
/*firstly creting a table SuspensionHistory to store record of members suspension and date*/
CREATE TABLE SuspensionHistory(
MemberID INT,
SuspensionDate DATE,
FOREIGN KEY (MemberID) REFERENCES Member (MemberID)
);
/*creating a trigger to add data to suspension history table whenever the member has been suspended
based on business rules*/
DELIMITER //
DROP TRIGGER IF EXISTS suspension;
//
CREATE TRIGGER suspension
AFTER UPDATE ON Member
FOR EACH ROW
BEGIN
    DECLARE v_status varchar(50);
    DECLARE v_id int;
    SELECT MemberStatus  INTO v_status
    FROM Member 
    WHERE MemberID = NEW.MemberID;

    IF v_status = 'SUSPENDED' THEN
		SELECT MemberID  INTO v_id
		FROM Member 
		WHERE MemberID = NEW.MemberID;

        
        INSERT INTO SuspensionHistory (MemberID, SuspensionDate)
        VALUES (v_id, CURDATE()); 
	END IF;
END;
//
DELIMITER ;

/*finally created a stored procedure with error handler*/
DROP PROCEDURE IF EXISTS TerminatedMember;

DELIMITER //
CREATE PROCEDURE TerminatedMember()
  BEGIN
    DECLARE v_finished INT DEFAULT 0;
    DECLARE v_id INT;
        
    DECLARE terminate_cursor CURSOR FOR
		SELECT t1.MemberID
		FROM SuspensionHistory as t1
		JOIN Borrowedby as t2 ON t1.MemberID = t2.MemberID
		WHERE t1.SuspensionDate >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR) 
		AND t2.DateReturned IS NULL
		AND t2.ReturnDueDate < CURDATE()
		GROUP BY t1.MemberID
		HAVING COUNT(*) >= 2;    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;    
    OPEN terminate_cursor;    
		REPEAT
			FETCH terminate_cursor INTO v_id;
				IF  v_finished = 0 THEN
					UPDATE Member  
					SET MemberStatus = 'TERMINATED'
					WHERE MemberID = v_id;
				END IF;
		UNTIL v_finished
		END REPEAT;    
	CLOSE terminate_cursor;
    
  END //
DELIMITER ;

/*we will insert the following data to test*/
SELECT * FROM HOLDING;
#to test trigger for BR4 first i have inserted values in holding table
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('2', '5','10','1');
INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
VALUES ('7','REGULAR','Fayyaz','4 XYZ St','Lidcome','NSW','2024-01-01','0434567811');
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('2', '5','7','2023-08-10',NULL,'2023-08-30');


/* we will the following code multple times so that the memberid 7 will be susapended multiple time 
and suspension is recorded in suspension history table*/
UPDATE Member
set FineFee= FineFee+45
where MemberID = 7;
update member
set FineFee= 10
where MemberID = 7;
/* the member status has been updated to SUSPENDED*/
select * from member;
select * from suspensionhistory;

/*before calling the stored procedure we need drop procedures that will update memberstatus based on businnes rules
beacuse we just want set status of member as terminated who currently have an overdue item and their (individual) 
membership has been suspended twice in the past three years*/
DROP TRIGGER IF EXISTS suspension;
DROP TRIGGER IF EXISTS br8_member_fine;
DROP TRIGGER IF EXISTS br8_borrowedby;
DROP TRIGGER IF EXISTS br7;
DROP TRIGGER IF EXISTS br6;

/*running stored procedure TerminatedMember*/
CALL TerminatedMember();
SELECT MemberID FROM Member WHERE MemberStatus = 'TERMINATED';
/*we can see stored procedure is executed succesfully and set membertstatus as TERMINATED for memberid 5*/
select * from member;

desc member;

ALTER TABLE Member MODIFY MemberStatus CHAR(11);

