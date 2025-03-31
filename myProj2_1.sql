select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;

--Project task
--**Task 1. Create a New Book Record**
-->"978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books(isbn,book_title,category,rental_price,status,author,publisher) 
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;
--**Task 2: Update an Existing Member's Address
update members set member_address='125 Main St' where member_id='C101';
select * from members;

--**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
 delete from issued_status where issued_id='IS121';
 
--**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
 select * from issued_status where issued_emp_id='E101';

--**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_member_id,count(issued_book_name) as No_of_books_issued from issued_status
  group by issued_member_id having count(issued_book_name)>1;
  -- members issued more than one book
  select issued_member_id from issued_status
  group by issued_member_id having count(issued_book_name)>1;

 --### 3. CTAS (Create Table As Select)

-- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results
-- each book and total book_issued_cnt**
select * from books;
select *from issued_status;

Create table book_cnt as
select b.isbn,b.book_title,count(c.issued_book_isbn)as no_count from books as b Join issued_status as c 
on b.isbn=c.issued_book_isbn group by 1,2;
select * from book_cnt;

--### 4. Data Analysis & Findings

--The following SQL queries were used to address specific questions:

--Task 7. **Retrieve All Books in a Specific Category**:
select * from books where category = 'Classic';
--No. of books in each category;
select category, count(book_title) as Books_count from books group by 1;

--8. **Task 8: Find Total Rental Income by Category**:
select b.category,sum(b.rental_price), count(*) from books as b join
issued_status as c on c.issued_book_isbn=b.isbn group by 1;

--9. **List Members Who Registered in the Last 180 Days**:
select * from members
insert into members(member_id,member_name,member_address,reg_date) values ('C120','Mohan','128 main st','2025-01-16'); 
insert into members(member_id,member_name,member_address,reg_date) values ('C121','rohan','228 main st','2025-02-04'); 

select * from members where reg_date <= current_date - interval '180 days'
select current_date

--10. **List Employees with Their Branch Manager's Name and their branch details**:
--(inner join example)
select * from employees;
select * from branch;
select e1.*,b.manager_id,e2.emp_name as manager from employees as e1 JOIN branch as b ON b.branch_id=e1.branch_id
JOIN employees as e2 ON b.manager_id=e2.emp_id;

--Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
select * from books;
Create table expensive_books as
select * from books  where rental_price >7 ;

--Task 12: **Retrieve the List of Books Not Yet Returned**
select * from return_status;
select * from issued_status as ist left join return_status as rst on ist.issued_id = rst.issued_id
where rst.return_id is null;
