-- Task 1.1: Basic CHECK Constraint

CREATE TABLE employees (
                           employee_id INTEGER,
                           first_name TEXT,
                           last_name TEXT,
                           age INTEGER CHECK (age BETWEEN 18 AND 65),
                           salary NUMERIC CHECK (salary > 0)
);

-- Task 1.1: Valid data

INSERT INTO employees
(employee_id, first_name, last_name, age, salary)
VALUES
    (1, 'Aruzhan', 'Sadykova', 20, 250000),
    (2, 'Madina', 'Aliyeva', 22, 320000);

-- Task 1.2: Named CHECK Constraint

CREATE TABLE products_catalog (
                                  product_id INTEGER,
                                  product_name TEXT,
                                  regular_price NUMERIC,
                                  discount_price NUMERIC,

                                  CONSTRAINT valid_discount
                                      CHECK (
                                          regular_price > 0
                                              AND discount_price > 0
                                              AND discount_price < regular_price
                                          )
);

INSERT INTO products_catalog
(product_id, product_name, regular_price, discount_price)
VALUES
    (1, 'Headphones', 20000, 15000),
    (2, 'Keyboard', 30000, 25000);

-- Task 1.3: Multiple Column CHECK

CREATE TABLE bookings (
                          booking_id INTEGER,
                          check_in_date DATE,
                          check_out_date DATE,
                          num_guests INTEGER,

                          CHECK (num_guests BETWEEN 1 AND 10),
                          CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings
(booking_id, check_in_date, check_out_date, num_guests)
VALUES
    (1, '2026-10-15', '2026-10-18', 2),
    (2, '2026-11-01', '2026-11-05', 4);

-- Check employees

SELECT * FROM employees;

-- Check products_catalog

SELECT * FROM products_catalog;

-- Check bookings

SELECT * FROM bookings;

-- =========================================
-- PART 2: NOT NULL CONSTRAINTS
-- Task 2.1: NOT NULL Implementation
-- =========================================

CREATE TABLE customers (
                           customer_id INTEGER NOT NULL,
                           email TEXT NOT NULL,
                           phone TEXT,
                           registration_date DATE NOT NULL
);

-- Insert valid customers

INSERT INTO customers
(customer_id, email, phone, registration_date)
VALUES
    (1, 'arina@gmail.com', '87001234567', '2026-10-01'),
    (2, 'madina@gmail.com', '87007654321', '2026-10-05'),
    (3, 'dana@gmail.com', NULL, '2026-10-10');


-- Task 2.2: Combining Constraints

CREATE TABLE inventory (
                           item_id INTEGER NOT NULL,
                           item_name TEXT NOT NULL,
                           quantity INTEGER NOT NULL CHECK (quantity >= 0),
                           unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
                           last_updated TIMESTAMP NOT NULL
);

-- Insert valid inventory records

INSERT INTO inventory
(item_id, item_name, quantity, unit_price, last_updated)
VALUES
    (1, 'Laptop', 10, 450000, '2026-10-11 10:00:00'),
    (2, 'Mouse', 25, 5000, '2026-10-11 11:30:00'),
    (3, 'Keyboard', 0, 15000, '2026-10-11 12:00:00');

-- Task 2.3: Testing NOT NULL

-- Check customers
SELECT * FROM customers;

-- Check inventory
SELECT * FROM inventory;

-- =========================================
-- PART 3: UNIQUE CONSTRAINTS
-- Task 3.1: Single Column UNIQUE
-- =========================================

CREATE TABLE users (
                       user_id INTEGER,
                       username TEXT UNIQUE,
                       email TEXT UNIQUE,
                       created_at TIMESTAMP
);

-- Insert valid users

INSERT INTO users (user_id, username, email, created_at)
VALUES
    (1, 'arina01', 'arina@gmail.com', '2026-10-11 10:00:00'),
    (2, 'madina02', 'madina@gmail.com', '2026-10-11 11:00:00'),
    (3, 'dana03', 'dana@gmail.com', '2026-10-11 12:00:00');

SELECT * FROM users;

-- =========================================
-- Task 3.2: Multi-Column UNIQUE
-- =========================================

CREATE TABLE course_enrollments (
                                    enrollment_id INTEGER,
                                    student_id INTEGER,
                                    course_code TEXT,
                                    semester TEXT,

                                    UNIQUE (student_id, course_code, semester)
);

-- Insert valid course enrollments

INSERT INTO course_enrollments
(enrollment_id, student_id, course_code, semester)
VALUES
    (1, 101, 'CS101', 'Fall 2026'),
    (2, 101, 'CS102', 'Fall 2026'),
    (3, 102, 'CS101', 'Fall 2026'),
    (4, 101, 'CS101', 'Spring 2027');

-- Task 3.3: Remove automatically named constraints

ALTER TABLE users
    DROP CONSTRAINT users_username_key;

ALTER TABLE users
    DROP CONSTRAINT users_email_key;

-- Add named UNIQUE constraints

ALTER TABLE users
    ADD CONSTRAINT unique_username UNIQUE (username);

ALTER TABLE users
    ADD CONSTRAINT unique_email UNIQUE (email);

-- =========================================
-- Verification: Part 3
-- =========================================

SELECT * FROM users;

SELECT * FROM course_enrollments;

SELECT
    conname AS constraint_name,
    contype AS constraint_type
FROM pg_constraint
WHERE conrelid = 'users'::regclass;

-- =========================================
-- PART 4: PRIMARY KEY CONSTRAINTS
-- Task 4.1: Single Column Primary Key
-- =========================================

CREATE TABLE departments (
                             dept_id INTEGER PRIMARY KEY,
                             dept_name TEXT NOT NULL,
                             location TEXT
);


-- Insert valid departments

INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (1, 'IT Department', 'Almaty'),
    (2, 'Finance Department', 'Astana'),
    (3, 'HR Department', 'Shymkent');

SELECT * FROM departments;

-- =========================================
-- Task 4.2: Composite Primary Key
-- =========================================

CREATE TABLE student_courses (
                                 student_id INTEGER,
                                 course_id INTEGER,
                                 enrollment_date DATE,
                                 grade TEXT,

                                 PRIMARY KEY (student_id, course_id)
);

-- Insert valid student courses

INSERT INTO student_courses
(student_id, course_id, enrollment_date, grade)
VALUES
    (101, 1, '2026-09-01', 'A'),
    (101, 2, '2026-09-02', 'B'),
    (102, 1, '2026-09-01', 'A'),
    (103, 3, '2026-09-03', 'B');

SELECT * FROM student_courses;

SELECT
    conrelid::regclass AS table_name,
    conname AS constraint_name
FROM pg_constraint
WHERE contype = 'p'
  AND conrelid IN (
                   'departments'::regclass,
                   'student_courses'::regclass
    );

-- =========================================
-- PART 5: FOREIGN KEY CONSTRAINTS
-- Task 5.1: Basic Foreign Key
-- =========================================

CREATE TABLE employees_dept (
                                emp_id INTEGER PRIMARY KEY,
                                emp_name TEXT NOT NULL,
                                dept_id INTEGER REFERENCES departments(dept_id),
                                hire_date DATE
);


-- Insert employees with valid department IDs

INSERT INTO employees_dept
(emp_id, emp_name, dept_id, hire_date)
VALUES
    (1, 'Aruzhan', 1, '2025-06-01'),
    (2, 'Madina', 2, '2025-08-15'),
    (3, 'Dana', 3, '2026-01-10');

SELECT * FROM employees_dept;

-- =========================================
-- Task 5.2: Library Database
-- Table: authors
-- =========================================

CREATE TABLE authors (
                         author_id INTEGER PRIMARY KEY,
                         author_name TEXT NOT NULL,
                         country TEXT
);

INSERT INTO authors (author_id, author_name, country)
VALUES
    (1, 'George Orwell', 'United Kingdom'),
    (2, 'J.K. Rowling', 'United Kingdom'),
    (3, 'Abai Kunanbayev', 'Kazakhstan'),
    (4, 'Stephen King', 'United States'),
    (5, 'Paulo Coelho', 'Brazil');

-- Table: publishers

CREATE TABLE publishers (
                            publisher_id INTEGER PRIMARY KEY,
                            publisher_name TEXT NOT NULL,
                            city TEXT
);

INSERT INTO publishers (publisher_id, publisher_name, city)
VALUES
    (1, 'Penguin Books', 'London'),
    (2, 'Bloomsbury', 'London'),
    (3, 'Kazakh Publishing House', 'Almaty'),
    (4, 'Scribner', 'New York'),
    (5, 'HarperCollins', 'New York');

-- Table: books

CREATE TABLE books (
                       book_id INTEGER PRIMARY KEY,
                       title TEXT NOT NULL,
                       author_id INTEGER REFERENCES authors(author_id),
                       publisher_id INTEGER REFERENCES publishers(publisher_id),
                       publication_year INTEGER,
                       isbn TEXT UNIQUE
);

INSERT INTO books
(book_id, title, author_id, publisher_id, publication_year, isbn)
VALUES
    (1, '1984', 1, 1, 1949, 'ISBN001'),
    (2, 'Harry Potter', 2, 2, 1997, 'ISBN002'),
    (3, 'The Path of Abai', 3, 3, 1942, 'ISBN003'),
    (4, 'The Shining', 4, 4, 1977, 'ISBN004'),
    (5, 'The Alchemist', 5, 5, 1988, 'ISBN005');

SELECT * FROM authors;

SELECT * FROM publishers;

SELECT * FROM books;

SELECT
    books.title,
    authors.author_name,
    publishers.publisher_name,
    books.publication_year
FROM books
         JOIN authors
              ON books.author_id = authors.author_id
         JOIN publishers
              ON books.publisher_id = publishers.publisher_id;

-- =========================================
-- Task 5.3: ON DELETE Options
-- Table: categories
-- =========================================

CREATE TABLE categories (
                            category_id INTEGER PRIMARY KEY,
                            category_name TEXT NOT NULL
);

INSERT INTO categories (category_id, category_name)
VALUES
    (1, 'Electronics'),
    (2, 'Books'),
    (3, 'Clothing');

-- Table: products_fk

CREATE TABLE products_fk (
                             product_id INTEGER PRIMARY KEY,
                             product_name TEXT NOT NULL,
                             category_id INTEGER REFERENCES categories(category_id)
                                 ON DELETE RESTRICT
);

INSERT INTO products_fk (product_id, product_name, category_id)
VALUES
    (1, 'Laptop', 1),
    (2, 'Smartphone', 1),
    (3, 'Novel', 2);

SELECT * FROM categories;

-- Table: orders

CREATE TABLE orders (
                        order_id INTEGER PRIMARY KEY,
                        order_date DATE NOT NULL
);

-- Table: order_items

CREATE TABLE order_items (
                             item_id INTEGER PRIMARY KEY,
                             order_id INTEGER REFERENCES orders(order_id)
                                 ON DELETE CASCADE,
                             product_id INTEGER REFERENCES products_fk(product_id),
                             quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO orders (order_id, order_date)
VALUES
    (1, '2026-10-10'),
    (2, '2026-10-11'),
    (3, '2026-10-11');

INSERT INTO order_items
(item_id, order_id, product_id, quantity)
VALUES
    (1, 1, 1, 2),
    (2, 1, 2, 1),
    (3, 2, 3, 3),
    (4, 3, 1, 1);

SELECT * FROM order_items;

DELETE FROM orders
WHERE order_id = 1;

-- =========================================
-- PART 6: E-COMMERCE DATABASE DESIGN
-- Task 6.1: Customers
-- =========================================
-- Create a separate schema for the e-commerce project

CREATE SCHEMA IF NOT EXISTS ecommerce;

CREATE TABLE customers (
                           customer_id INTEGER PRIMARY KEY,
                           name TEXT NOT NULL,
                           email TEXT UNIQUE NOT NULL,
                           phone TEXT,
                           registration_date DATE NOT NULL
);

-- Insert customers

INSERT INTO customers
(customer_id, name, email, phone, registration_date)
VALUES
    (1, 'Aruzhan', 'aruzhan@gmail.com', '87001234567', '2026-10-01'),
    (2, 'Madina', 'madina@gmail.com', '87007654321', '2026-10-02'),
    (3, 'Dana', 'dana@gmail.com', '87001112233', '2026-10-03'),
    (4, 'Ali', 'ali@gmail.com', '87009998877', '2026-10-04'),
    (5, 'Amina', 'amina@gmail.com', '87005554433', '2026-10-05');

-- Task 6.1: Products

CREATE TABLE products (
                          product_id INTEGER PRIMARY KEY,
                          name TEXT NOT NULL,
                          description TEXT,
                          price NUMERIC NOT NULL CHECK (price >= 0),
                          stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

INSERT INTO products
(product_id, name, description, price, stock_quantity)
VALUES
    (1, 'Laptop', 'Laptop for students', 450000, 10),
    (2, 'Mouse', 'Wireless mouse', 5000, 50),
    (3, 'Keyboard', 'Mechanical keyboard', 15000, 25),
    (4, 'Monitor', '24-inch monitor', 80000, 15),
    (5, 'Headphones', 'Wireless headphones', 20000, 30);

CREATE TABLE ecommerce.customers (
                                     customer_id INTEGER PRIMARY KEY,
                                     name TEXT NOT NULL,
                                     email TEXT UNIQUE NOT NULL,
                                     phone TEXT,
                                     registration_date DATE NOT NULL
);

INSERT INTO ecommerce.customers
(customer_id, name, email, phone, registration_date)
VALUES
    (1, 'Aruzhan', 'aruzhan@gmail.com', '87001234567', '2026-10-01'),
    (2, 'Madina', 'madina@gmail.com', '87007654321', '2026-10-02'),
    (3, 'Dana', 'dana@gmail.com', '87001112233', '2026-10-03'),
    (4, 'Ali', 'ali@gmail.com', '87009998877', '2026-10-04'),
    (5, 'Amina', 'amina@gmail.com', '87005554433', '2026-10-05');

CREATE TABLE ecommerce.products (
                                    product_id INTEGER PRIMARY KEY,
                                    name TEXT NOT NULL,
                                    description TEXT,
                                    price NUMERIC NOT NULL CHECK (price >= 0),
                                    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

INSERT INTO ecommerce.products
(product_id, name, description, price, stock_quantity)
VALUES
    (1, 'Laptop', 'Laptop for students', 450000, 10),
    (2, 'Mouse', 'Wireless mouse', 5000, 50),
    (3, 'Keyboard', 'Mechanical keyboard', 15000, 25),
    (4, 'Monitor', '24-inch monitor', 80000, 15),
    (5, 'Headphones', 'Wireless headphones', 20000, 30);

-- Task 6.1: Orders

CREATE TABLE ecommerce.orders (
                                  order_id INTEGER PRIMARY KEY,
                                  customer_id INTEGER NOT NULL,
                                  order_date DATE NOT NULL,
                                  total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
                                  status TEXT NOT NULL
                                      CHECK (
                                          status IN (
                                                     'pending',
                                                     'processing',
                                                     'shipped',
                                                     'delivered',
                                                     'cancelled'
                                              )
                                          ),

                                  CONSTRAINT fk_order_customer
                                      FOREIGN KEY (customer_id)
                                          REFERENCES ecommerce.customers(customer_id)
                                          ON DELETE RESTRICT
);

INSERT INTO ecommerce.orders
(order_id, customer_id, order_date, total_amount, status)
VALUES
    (1, 1, '2026-10-06', 455000, 'pending'),
    (2, 2, '2026-10-07', 20000, 'processing'),
    (3, 3, '2026-10-08', 95000, 'shipped'),
    (4, 4, '2026-10-09', 450000, 'delivered'),
    (5, 5, '2026-10-10', 15000, 'cancelled');

-- Task 6.1: Order Details

CREATE TABLE ecommerce.order_details (
                                         order_detail_id INTEGER PRIMARY KEY,
                                         order_id INTEGER NOT NULL,
                                         product_id INTEGER NOT NULL,
                                         quantity INTEGER NOT NULL CHECK (quantity > 0),
                                         unit_price NUMERIC NOT NULL CHECK (unit_price >= 0),

                                         CONSTRAINT fk_detail_order
                                             FOREIGN KEY (order_id)
                                                 REFERENCES ecommerce.orders(order_id)
                                                 ON DELETE CASCADE,

                                         CONSTRAINT fk_detail_product
                                             FOREIGN KEY (product_id)
                                                 REFERENCES ecommerce.products(product_id)
                                                 ON DELETE RESTRICT
);

INSERT INTO ecommerce.order_details
(order_detail_id, order_id, product_id, quantity, unit_price)
VALUES
    (1, 1, 1, 1, 450000),
    (2, 1, 2, 1, 5000),
    (3, 2, 5, 1, 20000),
    (4, 3, 4, 1, 80000),
    (5, 3, 3, 1, 15000);

-- Check customers
SELECT * FROM ecommerce.customers;

-- Check products
SELECT * FROM ecommerce.products;

-- Check orders
SELECT * FROM ecommerce.orders;

-- Check order_details
SELECT * FROM ecommerce.order_details;

SELECT
    o.order_id,
    c.name AS customer_name,
    p.name AS product_name,
    od.quantity,
    od.unit_price,
    o.status
FROM ecommerce.orders o
         JOIN ecommerce.customers c
              ON o.customer_id = c.customer_id
         JOIN ecommerce.order_details od
              ON o.order_id = od.order_id
         JOIN ecommerce.products p
              ON od.product_id = p.product_id
ORDER BY o.order_id;

SELECT COUNT(*) AS total_customers
FROM ecommerce.customers;

SELECT COUNT(*) AS total_products
FROM ecommerce.products;

SELECT COUNT(*) AS total_orders
FROM ecommerce.orders;

SELECT COUNT(*) AS total_order_details
FROM ecommerce.order_details;

