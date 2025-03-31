--SQL - Library Management Project 2
select * from books
select * from members
select * from employees
select * from branch
select * from issued_status
select * from return_status

--**Task 13: Identify Members with Overdue Books**  
/*Write a query to identify members who have overdue books (assume a 300-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue.*/
select m.member_id,
m.member_name,
b.book_title,
ist.issued_date
--r.return_date
,current_date-ist.issued_date as over_due_date
 from members as m 
 join 
 issued_status as ist on m.member_id=ist.issued_member_id 
 join
 books as b on b.isbn=ist.issued_book_isbn
 left join
 return_status as r on ist.issued_id=r.issued_id 
 where r.return_date is null 
                        and (current_date-ist.issued_date )>'300' order by 1
						

/* **Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
 
create or replace procedure return_records(p_return_id varchar(10),p_issued_id varchar(10),
 p_book_quality varchar(10))
 Language plpgsql as $$

Declare 
v_isbn varchar(50);
v_book_name  varchar(80);
Begin
--login code
--inserting input 
insert into return_status(return_id,issued_id,return_date,book_quality)
values(p_return_id,p_issued_id ,current_date, p_book_quality);

 select issued_book_isbn, issued_book_name
 from issued_status into v_isbn, v_book_name
 where issued_id=p_issued_id;

 Update books Set status='yes'
 where isbn = v_isbn;

 raise notice ' Thank you for returning the book:%',v_book_name ;


End; 
$$

 call return_records()

 -- Testing FUNCTION return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL return_records('RS138', 'IS135', 'Good');

CALL return_records('RS140', 'IS140', 'Good');


/**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books 
issued, the number of books returned, and the total revenue generated from book rentals.
*/
CREATE TABLE Branch_Report
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM Branch_Report;

/**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing
members who have issued at least one book in the last 2 months.
*/

CREATE TABLE Active_Members AS

SELECT * FROM members
WHERE member_id IN 
             (SELECT 
              DISTINCT issued_member_id   
              FROM issued_status
               WHERE  issued_date >= CURRENT_DATE - INTERVAL '6 month'
                );


SELECT * FROM Active_Members;

/**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues.
Display the employee name, number of books processed, and their branch.
*/
select * from issued_status
select * from employees

select e.emp_name,count(i.issued_book_isbn) as books_processed,e.branch_id 
from employees as e
left join
issued_status as i on e.emp_id=i.issued_emp_id
group by 1,3 
order by 2 desc
limit 3 ;

/**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged"in the
books table. Display the member name, book title, and the number of times they've issued damaged books. 
*/

/**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance.
The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating
that the book is currently not available.
*/
CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(30),
p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

    INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
     VALUES
      (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'


/**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
*/