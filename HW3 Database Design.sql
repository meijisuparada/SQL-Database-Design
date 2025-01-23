-- MBAn 555 - HW3 Database Design
-- Meiji Supakamolsenee

-- 1) Attached on the other file

-- 2) Write the CREATE SQL code for creating the database and all the tables in there
CREATE DATABASE um_ross;
USE um_ross;

-- Create Table: Program
CREATE TABLE program (
    program_name VARCHAR(100) NOT NULL,
    program_type ENUM('undergraduate', 'graduate') NOT NULL,
    duration INT,
    start_date DATE,
    description TEXT,
    PRIMARY KEY (program_name)
);

-- Create Table: Buildings
CREATE TABLE buildings (
    building_id INT NOT NULL AUTO_INCREMENT,
    building_name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    description TEXT,
    PRIMARY KEY (building_id)
);

-- Create Table: Rooms (linked to buildings)
CREATE TABLE rooms (
    room_id INT NOT NULL AUTO_INCREMENT,
    building_id INT NOT NULL,
    room_number VARCHAR(20),
    capacity INT,
    PRIMARY KEY (room_id),
    FOREIGN KEY (building_id) REFERENCES buildings(building_id) ON DELETE CASCADE
);

-- Create Table: Departments
CREATE TABLE departments (
    department_id INT NOT NULL AUTO_INCREMENT,
    program_name VARCHAR(100),
    head_of_department INT,
    PRIMARY KEY (department_id),
    FOREIGN KEY (program_name) REFERENCES program(program_name) ON DELETE SET NULL
);

-- Create Table: Faculty (references rooms and departments)
CREATE TABLE faculty (
    faculty_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender ENUM('m','f') NOT NULL,
    department_id INT,
    program_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(15),
    title VARCHAR(100),
    room_id INT,
    PRIMARY KEY (faculty_id),
    FOREIGN KEY (program_name) REFERENCES program(program_name) ON DELETE SET NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    FOREIGN KEY (room_id) REFERENCES rooms(room_id) ON DELETE SET NULL
);

-- Create Table: Student
CREATE TABLE student (
    student_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    gender ENUM('m','f') NOT NULL,
    birth_date DATE,
    phone_number VARCHAR(15),
    address VARCHAR(255),
    program_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    class ENUM('freshman', 'sophomore', 'junior', 'senior', 'oym', 'mba') NOT NULL,
    year_enrolled YEAR,
    expected_graduation_year YEAR,
    status ENUM('active', 'inactive', 'graduated') NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (program_name) REFERENCES program(program_name) ON DELETE CASCADE
);


CREATE INDEX idx_student_email ON student(email);
CREATE INDEX idx_faculty_department ON faculty(department_id);


-- 3) Write INSERT commands to add a few rows of data for each of the tables
-- Insert into program
INSERT INTO program (program_name, program_type, duration, start_date, description)
VALUES 
('MBA', 'graduate', 24, '2023-09-01', 'Master of Business Administration'),
('BBA', 'undergraduate', 48, '2022-09-01', 'Bachelor of Business Administration'),
('OYM', 'graduate', 12, '2023-09-01', 'One Year Master Program');

-- Insert into buildings
INSERT INTO buildings (building_name, location, description)
VALUES 
('Ross Building', 'Ann Arbor, MI', 'Main building for business programs'),
('Blau Hall', 'Ann Arbor, MI', 'Secondary business school building');

-- Insert into rooms
INSERT INTO rooms (building_id, room_number, capacity)
VALUES 
(1, '101', 50),
(1, '102', 75),
(2, '201', 100);

-- Insert into departments
INSERT INTO departments (program_name, head_of_department)
VALUES 
('MBA', NULL),
('BBA', NULL),
('OYM', NULL);

-- Insert into faculty (make sure department_id values 1 and 2 exist in departments)
INSERT INTO faculty (first_name, last_name, gender, department_id, program_name, email, phone_number, title, room_id)
VALUES 
('Sanjeev', 'Kumar', 'm', 1, 'OYM', 'sankum@umich.edu', '1234567890', 'Professor', 1),
('Jane', 'Smith', 'f', 2, 'BBA', 'janesmith@umich.edu', '0987654321', 'Associate Professor', 2);

-- Update departments with head_of_department references
-- Use the correct faculty who are inserted above
UPDATE departments 
SET head_of_department = (SELECT faculty_id FROM faculty WHERE first_name = 'Sanjeev' AND last_name = 'Kumar') 
WHERE program_name = 'OYM';

UPDATE departments 
SET head_of_department = (SELECT faculty_id FROM faculty WHERE first_name = 'Jane' AND last_name = 'Smith') 
WHERE program_name = 'BBA';

-- Insert into student (ensure that the programs 'BBA' and 'MBA' exist in program table)
INSERT INTO student (first_name, last_name, gender, birth_date, phone_number, address, program_name, email, class, year_enrolled, expected_graduation_year, status)
VALUES 
('Alice', 'Brown', 'f', '2001-05-21', '1122334455', '123 Main St, Ann Arbor, MI', 'BBA', 'alice.brown@umich.edu', 'junior', 2022, 2026, 'active'),
('Bob', 'Green', 'm', '1999-11-30', '2233445566', '456 Elm St, Ann Arbor, MI', 'MBA', 'bob.green@umich.edu', 'oym', 2023, 2025, 'active');

-- 4) Write UPDATE commands to update data in the database
-- Update the address of a student based on their name
UPDATE student
SET address = '987 Oak St, Ann Arbor, MI'
WHERE first_name = 'Alice' AND last_name = 'Brown';

-- Promote a faculty member to 'Senior Professor'
UPDATE faculty
SET title = 'Senior Professor'
WHERE first_name = 'Sanjeev' AND last_name = 'Kumar';

-- Move a student from 'BBA' to 'MBA' program
UPDATE student
SET program_name = 'MBA'
WHERE first_name = 'Alice' AND last_name = 'Brown';

-- 5) Test SELECT Commands to Ensure Tables are Working as Expected
-- Retrieve all programs to confirm that the data has been inserted correctly.
SELECT * FROM program;
-- returns 3 rows

-- Count the number of faculty members per department to test `department_id` connections
SELECT d.department_id, d.program_name, COUNT(f.faculty_id) AS faculty_count
FROM departments d
LEFT JOIN faculty f ON d.department_id = f.department_id
GROUP BY d.department_id;
-- returns 3 rows

-- List all students belonging to a specific program (e.g., 'MBA')
SELECT first_name, last_name, class
FROM student
WHERE program_name = 'MBA';
-- returns 2 rows







