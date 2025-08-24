
DELETE FROM Author;
INSERT INTO Author (AuthorID,AuthorName,AuthorAddress ) 
VALUES ('1', 'Tolstoy','Russian Empire');
INSERT INTO Author (AuthorID,AuthorName,AuthorAddress ) 
VALUES ('2', 'Tolkien','England');
INSERT INTO Author (AuthorID,AuthorName,AuthorAddress ) 
VALUES ('3', 'Asimov','America');
INSERT INTO Author (AuthorID,AuthorName,AuthorAddress ) 
VALUES ('4', 'Silverberg','America');
INSERT INTO Author (AuthorID,AuthorName,AuthorAddress ) 
VALUES ('5', 'Paterson','Australia');

select * from author;

DELETE FROM Branch;
INSERT INTO Branch (BranchID,BranchSuburb,BranchState) 
VALUES ('1','Parramatta','NSW');
INSERT INTO Branch (BranchID,BranchSuburb,BranchState) 
VALUES ('2','North Ryde','NSW');
INSERT INTO Branch (BranchID,BranchSuburb,BranchState) 
VALUES ('3','Sydney City','NSW');

select * from branch;

DELETE FROM Publisher;
INSERT INTO Publisher (PublisherID,PublisherName,PublisherAddress ) 
VALUES ('1','Penguin','New York');
INSERT INTO Publisher (PublisherID,PublisherName,PublisherAddress ) 
VALUES ('2','Platypus','Sydney');
INSERT INTO Publisher (PublisherID,PublisherName,PublisherAddress ) 
VALUES ('3','Another Choice','Patagonia');

select * from publisher;


INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
VALUES ('1','REGULAR','Joe','4 Nowhere St','Here','NSW','2021-09-30','0434567811');
INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
VALUES ('2','REGULAR','Pablo','10 Somewhere St','There','ACT','2022-09-30','0412345678');
INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
VALUES ('3','REGULAR','Chen','23/9 Faraway Cl','Far','QLD','2020-11-30','0412346578');
INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
VALUES ('4','REGULAR','Zhang','Dunno St','North','NSW','2020-12-31','');
INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
VALUES ('5','REGULAR','Saleem','44 Magnolia St','South','SA','2020-09-30','1234567811');
INSERT INTO Member (MemberID,MemberStatus,MemberName,MemberAddress,MemberSuburb,MemberState,MemberExpDate,MemberPhone) 
VALUES ('6','SUSPENDED','Homer','Middle of Nowhere','North Ryde','NSW','2020-09-30','1234555811');

DELETE FROM Book;
INSERT INTO Book (BookID,BookTitle,PublisherID,PublishedYear,Price )
VALUES ('1','Anna Karenina','1','2003',12.75);
INSERT INTO Book (BookID,BookTitle,PublisherID,PublishedYear,Price )
VALUES ('2','War and Peace','2','1869',139.99);
INSERT INTO Book (BookID,BookTitle,PublisherID,PublishedYear,Price )
VALUES ('3','The Hobbit','2','1937',9.19);
INSERT INTO Book (BookID,BookTitle,PublisherID,PublishedYear,Price )
VALUES ('4','I, Robot','2','1950',29.99);
INSERT INTO Book (BookID,BookTitle,PublisherID,PublishedYear,Price )
VALUES ('5','The Positronic Man','3','2010',125.99);

DELETE FROM Authoredby;
INSERT INTO Authoredby (BookID,AuthorID) VALUES ('1', '1');
INSERT INTO Authoredby (BookID,AuthorID) VALUES ('2', '1');
INSERT INTO Authoredby (BookID,AuthorID) VALUES ('3', '2');
INSERT INTO Authoredby (BookID,AuthorID) VALUES ('4', '3');
INSERT INTO Authoredby (BookID,AuthorID) VALUES ('5', '3');
INSERT INTO Authoredby (BookID,AuthorID) VALUES ('5', '4');

DELETE FROM Holding;
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('1', '1','2','2');
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('1', '2','2','1');
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('1', '3','3','1');
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('2', '1','1','1');
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('2', '4','3','2');
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('3', '4','4','0');
INSERT INTO Holding (BranchID,BookID,InStock,OnLoan) 
VALUES ('3', '5','2','1');

DELETE FROM Borrowedby;
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('1', '1','2',curdate(),NULL,date_add(curdate(),INTERVAL 3 WEEK));
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('2', '4','4',curdate(),NULL,date_add(curdate(),INTERVAL 3 WEEK));
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('2', '1','4',curdate(),NULL,date_add(curdate(),INTERVAL 3 WEEK));
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('2', '4','1',curdate(),NULL,date_add(curdate(),INTERVAL 3 WEEK));
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '5','3',curdate(),NULL,date_add(curdate(),INTERVAL 3 WEEK));
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('1', '1','1','2020-08-30',NULL,'2020-09-30');
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('1', '2','2','2020-08-30',NULL,'2020-09-30');
INSERT INTO Borrowedby (BranchID,BookID,MemberID,DateBorrowed,DateReturned,ReturnDueDate)
VALUES ('3', '4','2','2020-08-30',NULL,'2020-09-30');


