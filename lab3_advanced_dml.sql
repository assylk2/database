--PART A
CREATE DATABASE advance_lab;

CREATE TABLE employees (
    emp_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
                             dept_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                             dept_name VARCHAR(50),
                             budget INTEGER,
                             manager_id INTEGER
);

CREATE TABLE projects (
                          project_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                          project_name VARCHAR(100),
                          dept_id INTEGER,
                          start_date DATE,
                          end_date DATE,
                          budget INTEGER
);


--PART B
INSERT INTO employees
( first_name, last_name, department)
VALUES
    ( 'Aruzhan', 'Sarsenova', 'IT');

ALTER TABLE employees
ALTER COLUMN salary SET DEFAULT 50000;

INSERT INTO employees
    (first_name, last_name, salary, status)
VALUES
    ('Dana', 'Kim', DEFAULT, DEFAULT);

INSERT INTO departments
    (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('Sales', 120000, 2),
    ('HR', 90000, 3);

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
    ('Ali', 'Bekov', 'IT', 50000 * 1.1, CURRENT_DATE);

CREATE TEMP TABLE temp_employees AS
SELECT *
FROM employees
WHERE department = 'IT';


--PART C
UPDATE employees
SET salary = salary * 1.10;

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';

UPDATE employees
SET department =
        CASE
            WHEN salary > 80000 THEN 'Management'
            WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
            ELSE 'Junior'
        END;


ALTER TABLE employees
ALTER COLUMN department SET DEFAULT 'Unassigned';

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments d
SET budget = budget + (
    0.20 * (
        SELECT AVG(e.salary)
        FROM employees e
        WHERE e.department = d.dept_name
    )
    )
WHERE d.dept_name IS NOT NULL;

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

--PART D

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments d
WHERE d.dept_name NOT IN (
    SELECT DISTINCT e.department
    FROM employees e
    WHERE e.department IS NOT NULL
);

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

--PART E
INSERT INTO employees
(first_name, last_name, salary, department)
VALUES
    ('Aigerim', 'Nurlanova', NULL, NULL);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;


--PART F
INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
    ('Aruzhan', 'Sarsenova', 'IT', 60000, CURRENT_DATE)
RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;

WITH updated AS (
    SELECT emp_id, salary AS old_salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM updated u
WHERE e.emp_id = u.emp_id
RETURNING
    e.emp_id,
    u.old_salary,
    e.salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
SELECT
    'Aruzhan',
    'Sarsenova',
    'IT',
    60000,
    CURRENT_DATE
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Aruzhan'
      AND last_name = 'Sarsenova'
);

UPDATE employees e
SET salary =
        CASE
            WHEN d.budget > 100000 THEN e.salary * 1.10
            ELSE e.salary * 1.05
            END
FROM departments d
WHERE e.department = d.dept_name;

INSERT INTO employees
(first_name, last_name, department, salary, hire_date)
VALUES
    ('Ayan', 'Bek', 'IT', 50000, CURRENT_DATE),
    ('Dana', 'Kim', 'HR', 45000, CURRENT_DATE),
    ('Madi', 'Ali', 'Sales', 55000, CURRENT_DATE),
    ('Aruzhan', 'Lee', 'IT', 60000, CURRENT_DATE),
    ('Dias', 'Nur', 'Sales', 50000, CURRENT_DATE);

UPDATE employees
SET salary = salary * 1.10
WHERE (first_name, last_name) IN (
                                  ('Ayan', 'Bek'),
                                  ('Dana', 'Kim'),
                                  ('Madi', 'Ali'),
                                  ('Aruzhan', 'Lee'),
                                  ('Dias', 'Nur')
    );

CREATE TABLE employee_archive AS
SELECT *
FROM employees
WHERE FALSE;

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
          SELECT COUNT(*)
          FROM employees e
                   JOIN departments d
                        ON e.department = d.dept_name
          WHERE d.dept_id = p.dept_id
      ) > 3;