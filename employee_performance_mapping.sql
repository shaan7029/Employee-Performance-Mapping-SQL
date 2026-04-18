/* Project  : Employee Performance Mapping
-- Author   : Santanu Sarkar
-- Tool     : MySQL 8.0 / MySQL Workbench
-- Schema   : employee_cep1
-- Purpose  : SQL-based HR analytics for ScienceQtech startup
--            Covers DDL, DML, Window Functions, Stored Functions,
--            Views, Indexing, Subqueries, and Constraints
-- ============================================================*/


use employee_cep1;

CREATE DATABASE employee_cep1;
/* Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, and DEPARTMENT from the employee record table, 
and make a list of employees and details of their department.
*/
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM
    emp_record_table;
/*
Write a query to fetch EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPARTMENT, and EMP_RATING if the EMP_RATING is:
less than two
greater than four
between two and four
*/
SELECT 
    EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT, EMP_RATING
FROM
    emp_record_table
WHERE
    EMP_RATING < 2 OR EMP_RATING > 4
        OR EMP_RATING between 2 and 4; 

/* Write a query to concatenate the FIRST_NAME and the LAST_NAME of 
employees in the Finance department from the employee table and then give the resultant column alias as NAME.  
*/
SELECT 
    CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'NAME'
FROM
    emp_record_table
WHERE
    DEPT = 'FINANCE';

/* Write a SQL query to retrieve the employee ID, first name, role, 
and department of employees who hold leadership positions (Manager, President, or CEO).
*/
SELECT 
    EMP_ID, FIRST_NAME, ROLE, DEPT
FROM
    emp_record_table
WHERE
    ROLE IN ('MANAGER' , 'PRESIDENT', 'CEO');

/*
Write a query to list all the employees from the healthcare and 
finance departments using the union. Take data from the employee record table.
*/
SELECT 
    CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'NAME', DEPT
FROM
    emp_record_table
WHERE
    DEPT = 'HEALTHCARE' 
UNION SELECT 
    CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'NAME', DEPT
FROM
    emp_record_table
WHERE
    DEPT = 'FINANCE'
ORDER BY NAME;

/*Write a query to list employee details such as EMP_ID, 
FIRST_NAME, LAST_NAME, ROLE, DEPARTMENT, and EMP_RATING grouped by dept.
 Also include the respective employee rating along with the max emp rating for the department.
 */
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT, max(EMP_RATING) over(partition by DEPT) AS 'MAX_EMP_RATING_FOR_DEPT', EMP_RATING
FROM emp_record_table
order by dept;

/* Write a query to calculate the minimum and the maximum salary of the employees in each role. 
Take data from the employee record table.
*/
select FIRST_NAME, ROLE, min(SALARY) over(partition by ROLE) AS 'MIN_SALARY', max(SALARY) over(partition by ROLE) AS 'MAX_SALARY', SALARY
FROM emp_record_table;
# Alternative 
SELECT 
    ROLE,
    MIN(SALARY) AS 'MIN_SALARY',
    MAX(SALARY) AS 'MAX_SALARY'
FROM
    emp_record_table
GROUP BY ROLE
HAVING ROLE = 'ASSOCIATE DATA SCIENTIST'
    OR ROLE = 'JUNIOR DATA SCIENTIST'
    OR ROLE = 'LEAD DATA SCIENTIST'
    OR ROLE = 'MANAGER'
    OR ROLE = 'PRESIDENT'
    OR ROLE = 'SENIOR DATA SCIENTIST';
# Alternative
SELECT 
    ROLE,
    MIN(SALARY) AS 'MIN_SALARY',
    MAX(SALARY) AS 'MAX_SALARY'
FROM
    emp_record_table
GROUP BY ROLE
HAVING ROLE IN ('ASSOCIATE DATA SCIENTIST' , 'JUNIOR DATA SCIENTIST',
    'LEAD DATA SCIENTIST',
    'MANAGER',
    'PRESIDENT',
    'SENIOR DATA SCIENTIST');

/* Write a query to assign ranks to each employee based on their experience.
Take data from the employee record table.
*/
select *, dense_rank() over(order by EXP desc) as 'rank'
from emp_record_table;

/* Write a query to create a view that displays employees in 
various countries whose salary is more than six thousand. 
Take data from the employee record table.
*/
CREATE VIEW high_salary_employees AS
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS Name,
       COUNTRY, SALARY
FROM emp_record_table
WHERE SALARY > 6000;
SELECT * FROM high_salary_employees;

/*Write a nested query to find employees with experience of more than ten years.
 Take data from the employee record table. 
*/
SELECT 
    CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'Name', EXP
FROM
    emp_record_table
WHERE
    EMP_ID IN (SELECT 
            EMP_ID
        FROM
            emp_record_table
        WHERE
            EXP > 10);
            
/*Create an index to improve the cost and performance of the query 
to find the employee whose FIRST_NAME is ‘Eric’ in the employee table after
checking the execution plan.
*/

SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';
DROP INDEX idx_first_name ON emp_record_table;
SHOW INDEXES FROM emp_record_table;
SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';
CREATE INDEX idx_first_name ON emp_record_table(FIRST_NAME(50));
EXPLAIN SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';
SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';

/*Write a query to calculate the bonus for all the employees,
 based on their ratings and salaries (Use the formula: 5% of salary * employee rating).
 */
SELECT 
    EMP_ID,
    CONCAT(FIRST_NAME, ' ', LAST_NAME) AS 'Name',
    ROLE,
    SALARY,
    EMP_RATING,
    (SALARY * 0.05 * EMP_RATING) AS Bonus
FROM
    emp_record_table;

/* Write a query to calculate the average salary distribution based on the continent and country. 
Take data from the employee record table.
*/
select CONTINENT, COUNTRY, avg(SALARY) from emp_record_table
group by 1,2
order by CONTINENT;

/* Add CHECK constraint on EMP_RATING to allow only values between 1 and 5. 
Add UNIQUE constraint on combination of FIRST_NAME and LAST_NAME.
*/
create table employee_cep1.emp_record_tables_copy
as
select * from employee_cep1.emp_record_table;

alter table employee_cep1.emp_record_tables_copy
add constraint  chk1_emp_rating check (EMP_RATING between 1 and 5);

alter table employee_cep1.emp_record_tables_copy
add constraint unique_full_name unique (FIRST_NAME(50), LAST_NAME(50));

describe employee_cep1.emp_record_tables_copy;

/* Write a query that demonstrates the use of string, numeric, and date/time functions by performing the following:
a.
Extract the first three letters of each employee’s FIRST_NAME from the emp_record_table
b.
Calculate the square of the EMP_RATING using a numeric function
c.
Extract the month from the START_DATE in the proj_table
*/
SELECT 
    LEFT(FIRST_NAME, 3) AS First_3_Letters
FROM 
    emp_record_table;
    
SELECT 
    EMP_ID,
    EMP_RATING,
    POWER(EMP_RATING, 2) AS Rating_Squared
FROM 
    emp_record_table;   

SELECT 
    `START _DATE`, MONTH(`START _DATE`) AS Start_Month
FROM
    proj_table;    
    
/* 18.
Write two queries using subqueries to modify the dataset:
a.
Set EMP_RATING = 1 for employees with experience less than 1 year
b.
Remove employees from emp_record_table whose salary is below 2000 and who are not assigned to any project.
*/
SET SQL_SAFE_UPDATES = 0;
UPDATE emp_record_table
JOIN (
    SELECT EMP_ID
    FROM (
        SELECT EMP_ID
        FROM emp_record_table
        WHERE EXP < 1
    ) AS sub
) AS derived
ON emp_record_table.EMP_ID = derived.EMP_ID
SET emp_record_table.EMP_RATING = 1;

SELECT EMP_ID, EMP_RATING, EXP
FROM emp_record_table
WHERE EXP < 1;
SELECT COUNT(*) AS Updated_Count
FROM emp_record_table
WHERE EXP < 1 AND EMP_RATING = 1;
select * from emp_record_table;


DELETE FROM emp_record_table
WHERE EMP_ID IN (
    SELECT EMP_ID FROM (
        SELECT EMP_ID
        FROM emp_record_table
        WHERE SALARY < 2000 AND (PROJ_ID IS NULL OR PROJ_ID = '')
    ) AS sub
);
SELECT COUNT(*) AS Remaining_Employees
FROM emp_record_table;
