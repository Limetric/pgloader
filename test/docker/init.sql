CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;

CREATE TABLE departments (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE employees (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    status      ENUM('active', 'inactive', 'on_leave') NOT NULL DEFAULT 'active',
    hire_date   DATE NOT NULL,
    salary      DECIMAL(10, 2) NOT NULL,
    updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE dept_emp (
    employee_id   INT NOT NULL,
    department_id INT NOT NULL,
    PRIMARY KEY (employee_id, department_id),
    FOREIGN KEY (employee_id) REFERENCES employees(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO departments (name) VALUES
    ('Engineering'),
    ('Sales'),
    ('Marketing'),
    ('Support');

INSERT INTO employees (first_name, last_name, status, hire_date, salary) VALUES
    ('Alice',   'Smith',    'active',    '2020-01-15', 95000.00),
    ('Bob',     'Johnson',  'active',    '2019-06-01', 87500.50),
    ('Carol',   'Williams', 'on_leave',  '2021-03-22', 72000.00),
    ('David',   'Brown',    'active',    '2018-11-10', 110000.00),
    ('Eve',     'Davis',    'inactive',  '2017-08-05', 65000.75),
    ('Frank',   'Wilson',   'active',    '2022-02-28', 80000.00),
    ('Grace',   'Taylor',   'active',    '2023-07-14', 92000.00),
    ('Hank',    'Anderson', 'on_leave',  '2020-09-30', 78000.00),
    ('Ivy',     'Thomas',   'active',    '2021-12-01', 88000.25),
    ('Jack',    'Martinez', 'active',    '2024-01-08', 71000.00);

INSERT INTO dept_emp (employee_id, department_id) VALUES
    (1, 1), (2, 1), (3, 2), (4, 1),
    (5, 3), (6, 2), (7, 1), (8, 4),
    (9, 3), (10, 4);
