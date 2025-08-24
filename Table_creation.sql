create database library;
use library;
DROP TABLE IF EXISTS Borrowedby, Holding, Authoredby, Author, Book, Publisher, Member, Branch;

/*Table structure for table `branch` */
CREATE TABLE Branch (
  BranchID INT NOT NULL, 
  BranchSuburb varchar(255) NOT NULL,
  BranchState char(3) NOT NULL,
  PRIMARY KEY (BranchID)
);
desc branch;

CREATE TABLE Member (
  MemberID INT NOT NULL, 
  MemberStatus char(9) DEFAULT 'REGULAR',
  MemberName varchar(255) NOT NULL,
  MemberAddress varchar(255) NOT NULL,
  MemberSuburb varchar(25) NOT NULL,
  MemberState char(3) NOT NULL,
  MemberExpDate DATE,
  MemberPhone varchar(10),
  PRIMARY KEY (`MemberID`)
);

desc member;

CREATE TABLE Publisher (
  PublisherID INT NOT NULL, 
  PublisherName varchar(255) NOT NULL,
  PublisherAddress varchar(255) DEFAULT NULL,
  PRIMARY KEY (PublisherID)
);

CREATE TABLE Book (
  BookID INT NOT NULL,
  BookTitle varchar(255) NOT NULL,
  PublisherID INT NOT NULL,
  PublishedYear INT4,
  Price Numeric(5,2) NOT NULL,
  PRIMARY KEY (BookID),
  KEY PublisherID (PublisherID),
  CONSTRAINT publisher_fk_1 FOREIGN KEY (PublisherID) REFERENCES Publisher (PublisherID) ON DELETE RESTRICT
);

CREATE TABLE Author (
  AuthorID INT NOT NULL, 
  AuthorName varchar(255) NOT NULL,
  AuthorAddress varchar(255) NOT NULL,
  PRIMARY KEY (AuthorID)
);

CREATE TABLE Authoredby (
  BookID INT NOT NULL,
  AuthorID INT NOT NULL, 
  PRIMARY KEY (BookID,AuthorID),
  KEY BookID (BookID),
  KEY AuthorID (AuthorID),
  CONSTRAINT book_fk_1 FOREIGN KEY (BookID) REFERENCES Book (BookID) ON DELETE RESTRICT,
  CONSTRAINT author_fk_1 FOREIGN KEY (AuthorID) REFERENCES Author (AuthorID) ON DELETE RESTRICT
);

CREATE TABLE Holding (
  BranchID INT NOT NULL, 
  BookID INT NOT NULL,
  InStock INT DEFAULT 1,
  OnLoan INT DEFAULT 0,
  PRIMARY KEY (BranchID, BookID),
  KEY BookID (BookID),
  KEY BranchID (BranchID),
  CONSTRAINT holding_cc_1 CHECK(InStock>=OnLoan),
  CONSTRAINT book_fk_2 FOREIGN KEY (BookID) REFERENCES Book (BookID) ON DELETE RESTRICT,
  CONSTRAINT branch_fk_1 FOREIGN KEY (BranchID) REFERENCES Branch (BranchID) ON DELETE RESTRICT
);

CREATE TABLE Borrowedby (
  BookIssueID INT UNSIGNED NOT NULL AUTO_INCREMENT,
  BranchID INT NOT NULL,
  BookID INT NOT NULL,
  MemberID INT NOT NULL,
  DateBorrowed DATE,
  DateReturned DATE DEFAULT NULL,
  ReturnDueDate DATE,
  PRIMARY KEY (BookIssueID),
  KEY BookID (BookID),
  KEY BranchID (BranchID),
  KEY MemberID (MemberID),
  CONSTRAINT borrowedby_cc_1 CHECK(DateBorrowed<ReturnDueDate),
  CONSTRAINT holding_fk_1 FOREIGN KEY (BookID,BranchID) REFERENCES Holding (BookID,BranchID) ON DELETE RESTRICT,
  CONSTRAINT member_fk_1 FOREIGN KEY (MemberID) REFERENCES Member (MemberID) ON DELETE RESTRICT
) ;














