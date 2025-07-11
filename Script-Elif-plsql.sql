-- Create DEPARTMENTS table
CREATE TABLE departments (
    department_id   NUMBER PRIMARY KEY,
    department_name VARCHAR2(50)
);

-- Create EMPLOYEES table
CREATE TABLE employees (
    employee_id     NUMBER PRIMARY KEY,
    first_name      VARCHAR2(50),
    last_name       VARCHAR2(50),
    email           VARCHAR2(100),
    phone_number    VARCHAR2(20),
    hire_date       DATE,
    job_id          VARCHAR2(10),
    salary          NUMBER,
    department_id   NUMBER,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);


-- Insert departments
INSERT INTO departments VALUES (10, 'IT');
INSERT INTO departments VALUES (20, 'Sales');
INSERT INTO departments VALUES (30, 'HR');

-- Insert employees
INSERT INTO employees VALUES (100, 'Alice', 'Smith', 'ALICE.SMITH', '1234567890', TO_DATE('2018-01-10','YYYY-MM-DD'), 'IT_PROG', 5000, 10);
INSERT INTO employees VALUES (101, 'Bob', 'Jones', 'BOB.JONES', '1234567891', TO_DATE('2019-03-12','YYYY-MM-DD'), 'IT_PROG', 4800, 10);
INSERT INTO employees VALUES (102, 'Carol', 'Brown', 'CAROL.BROWN', '1234567892', TO_DATE('2020-06-18','YYYY-MM-DD'), 'SA_REP', 4500, 20);
INSERT INTO employees VALUES (103, 'David', 'Wilson', 'DAVID.WILSON', '1234567893', TO_DATE('2021-02-01','YYYY-MM-DD'), 'SA_REP', 4700, 20);
INSERT INTO employees VALUES (104, 'Eva', 'Miller', 'EVA.MILLER', '1234567894', TO_DATE('2022-07-20','YYYY-MM-DD'), 'HR_REP', 4400, 30);
INSERT INTO employees VALUES (105, 'Frank', 'Davis', 'FRANK.DAVIS', '1234567895', TO_DATE('2023-03-14','YYYY-MM-DD'), 'HR_REP', 4600, 30);
COMMIT;



SELECT * FROM employees;


-- ========================================
-- QUESTION 1: Names of all employees in a department, side-by-side in a single column
-- ========================================
SELECT department_id,
       LISTAGG(first_name || ' ' || last_name, ', ') 
         WITHIN GROUP (ORDER BY employee_id) AS employee_names
FROM employees
GROUP BY department_id;

-- ========================================
-- QUESTION 2: Sum of salaries of one-before and one-after employees (ordered by employee_id, grouped by job_id)
-- ========================================
SELECT employee_id, job_id, salary,
       NVL(LAG(salary) OVER (PARTITION BY job_id ORDER BY employee_id), 0) +
       NVL(LEAD(salary) OVER (PARTITION BY job_id ORDER BY employee_id), 0) AS sum_neighbors_salary
FROM employees;

-- ========================================
-- QUESTION 3: Phone number of the next employee (ordered by employee_id, grouped by job_id)
-- ========================================
SELECT employee_id, job_id, phone_number,
       LEAD(phone_number) OVER (PARTITION BY job_id ORDER BY employee_id) AS next_phone
FROM employees;

-- ========================================
-- QUESTION 4: Salary rank of all employees (if salaries match, use hire_date)
-- ========================================
SELECT employee_id, first_name, salary, hire_date,
       DENSE_RANK() OVER (ORDER BY salary DESC, hire_date ASC) AS salary_rank
FROM employees;

-- ========================================
-- QUESTION 5: Divide all employees into groups of 10 based on employee_id order
-- ========================================
SELECT employee_id, first_name,
       CEIL(ROWNUM / 10) AS group_of_10
FROM (SELECT * FROM employees ORDER BY employee_id);

-- ========================================
-- QUESTION 6: 0 if below dept average salary, 1 if above or equal
-- ========================================
SELECT employee_id, department_id, salary,
       CASE 
         WHEN salary >= AVG(salary) OVER (PARTITION BY department_id) THEN 1
         ELSE 0
       END AS above_average_flag
FROM employees;

-- ========================================
-- QUESTION 7: First hired employee each year
-- ========================================
SELECT * FROM (
    SELECT employee_id, first_name, hire_date,
           EXTRACT(YEAR FROM hire_date) AS hire_year,
           RANK() OVER (PARTITION BY EXTRACT(YEAR FROM hire_date) ORDER BY hire_date) AS rk
    FROM employees
)
WHERE rk = 1;

-- ========================================
-- QUESTION 8: List all employees in a department except the highest-paid one
-- ========================================
SELECT * FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM employees x
    WHERE x.department_id = e.department_id
      AND x.salary > e.salary
);

-- ========================================
-- QUESTION 9: Top 2 highest-paid employees per department
-- ========================================
SELECT * FROM (
    SELECT employee_id, department_id, salary,
           DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rnk
    FROM employees
)
WHERE rnk <= 2;

-- ========================================
-- QUESTION 10: Previous and next employee (based on hire date)
-- ========================================
SELECT employee_id, first_name || ' ' || last_name AS employee_name,
       LAG(first_name || ' ' || last_name) OVER (ORDER BY hire_date) AS previous_employee,
       LEAD(first_name || ' ' || last_name) OVER (ORDER BY hire_date) AS next_employee
FROM employees;
