CREATE TYPE NAME AS (FirstName VARCHAR, MiddleName VARCHAR, LastName VARCHAR);
CREATE TABLE IF NOT EXISTS Author(
	authorid INT UNIQUE NOT NULL,
	Address VARCHAR,
	Contact VARCHAR,
	Name NAME NOT NULL,
	PRIMARY KEY(authorid));

CREATE TABLE IF NOT EXISTS Book (
	ISBN VARCHAR UNIQUE NOT NULL,
	Title VARCHAR NOT NULL,
	Price MONEY CHECK(Price::numeric > 0),
	Pages INT CHECK(Pages > 0),
	PRIMARY KEY (ISBN));

CREATE TABLE IF NOT EXISTS Writes (
	AuthorID INT REFERENCES Author (Authorid) ON UPDATE CASCADE ON DELETE CASCADE,
	ISBN VARCHAR REFERENCES Book (ISBN) ON UPDATE CASCADE ON DELETE CASCADE,
	PRIMARY KEY(authorid, isbn));

CREATE TABLE IF NOT EXISTS TextBook(ISBN VARCHAR REFERENCES Book (ISBN) ON DELETE CASCADE,
	Subject VARCHAR, PRIMARY KEY(ISBN));

CREATE TABLE IF NOT EXISTS Novel(ISBN VARCHAR REFERENCES Book (ISBN) ON DELETE CASCADE,
	noveltype VARCHAR, PRIMARY KEY(ISBN));

CREATE TABLE IF NOT EXISTS Publisher(
	pid INT UNIQUE NOT NULL,
	name VARCHAR NOT NULL,
	established_date DATE,
	PRIMARY KEY (pid));

CREATE TABLE Published_By(isbn VARCHAR REFERENCES Book(isbn) ON UPDATE CASCADE ON DELETE CASCADE,
	pid INT REFERENCES Publisher(pid) ON UPDATE CASCADE ON DELETE CASCADE,
	pubid SERIAL PRIMARY KEY );

-- Populate with test data

--Authors
INSERT INTO Author(authorid, name, contact, address) VALUES(123, ('George', 'H', 'Washington'), 'Write me', '1600 Pennsylvania Ave');
INSERT INTO Author(authorid, name, contact, address) VALUES(234, ('Abe', 'J', 'Lincoln'), 'Write', 'Log cabin');
INSERT INTO Author(authorid, name, contact, address) VALUES(345, ('Teddy', 'B', 'Roosevelt'), 'Go hunting with me', 'On a Safari');
INSERT INTO Author(authorid, name, contact, address) VALUES(456, ('Andrew', 'M', 'Jackson'), 'In person', 'Defenind New Orleans');
INSERT INTO Author(authorid, name, contact, address) VALUES(567, ('Donald', 'N', 'Trump'), 'Call me', 'Trump Tower New York');

-- Books
INSERT INTO Book(isbn, title, price, pages) VALUES(123, 'Huck Finn', 10.99, 380);
INSERT INTO Book(isbn, title, price, pages) VALUES(234, 'Docker for Noobs', 3677.99, 245);
INSERT INTO Book(isbn, title, price, pages) VALUES(345, 'How to Cook Steak', 3.99, 45);
INSERT INTO Book(isbn, title, price, pages) VALUES(456, 'Truck Driving 101', 1239.99, 348);
INSERT INTO Book(isbn, title, price, pages) VALUES(567, 'Band of Brothers', 19.99, 407);

-- Associate Textbooks
INSERT INTO Textbook(isbn, subject) VALUES(234, 'Computer Science');
INSERT INTO Textbook(isbn, subject) VALUES(345, 'Cooking');
INSERT INTO Textbook(isbn, subject) VALUES(456, 'Transportation');

-- Associate Novels
INSERT INTO Novel(isbn, noveltype) VALUES(567, 'Historical WWII');
INSERT INTO Novel(isbn, noveltype) VALUES(123, 'American Literature');

-- Associate Authors with Books (Writes)
INSERT INTO Writes(authorid, isbn) VALUES(123, 123);
INSERT INTO Writes(authorid, isbn) VALUES(123, 234); --Test one author multiple books
INSERT INTO Writes(authorid, isbn) VALUES(234, 345);
INSERT INTO Writes(authorid, isbn) VALUES(345, 345); -- Test multiple authors one book
INSERT INTO Writes(authorid, isbn) VALUES(456, 456);
INSERT INTO Writes(authorid, isbn) VALUES(567, 567);

-- Publishers
INSERT INTO Publisher(pid, Name, established_date) VALUES(123, 'Isaac Publishing Inc.', '11-24-1995');
INSERT INTO Publisher(pid, Name, established_date) VALUES(234, 'Patton Press Ltd.', '09-23-1903');
INSERT INTO Publisher(pid, Name, established_date) VALUES(345, 'NovelCo', '04-13-1956');

-- Published By (This models the 1-many since there are multiple books for single publishers)
INSERT INTO Published_By(isbn, pid) VALUES(123, 345);
INSERT INTO Published_By(isbn, pid) VALUES(567, 345);
INSERT INTO Published_By(isbn, pid) VALUES(234, 123);
INSERT INTO Published_By(isbn, pid) VALUES(456, 123);
INSERT INTO Published_By(isbn, pid) VALUES(345, 234);

-- Select all authors who live in NY
SELECT * FROM Author WHERE Address LIKE '%New York%' OR ADDRESS LIKE '%NY%';

-- Count number of books written by each author 
-- Note 6 books since some were co-authored
SELECT AuthorID,COUNT(*) AS "Books Written" FROM Writes WHERE CAST(AuthorID as TEXT) LIKE '%' GROUP BY AuthorID;

-- Find all publisher name and (ISBN, title) of books published by them

-- List all authors who have written textbook with subject starting with C
WITH results AS (WITH author_c AS (WITH book_c AS (SELECT isbn FROM Textbook t WHERE t.Subject LIKE 'C%') SELECT * from book_c INNER JOIN Writes ON book_c.isbn = Writes.isbn) SELECT * FROM author_c INNER JOIN Author ON Author.authorid = author_c.authorid) SELECT Address AS "Author address where textbook subject starts with C" FROM results;

CREATE VIEW AuthorInfo (FirstName)  AS SELECT a.name FROM Author A;
