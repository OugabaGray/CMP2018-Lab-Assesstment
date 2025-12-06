-----------------------------------
--  DATABASE: JamaicaZoo2405837
--  Name: Ougaba Gray (2405837)
------------------------------------
---------------					---------------------
-- LAB ALPHA(1)					LAB BETA(2) is below
---------------         ---------------------
CREATE DATABASE JamaicaZoo2405837;
USE JamaicaZoo2405837;

-- Species Table
CREATE TABLE Species
(
	species_ID INT,
	common_Name VARCHAR(40) NOT NULL UNIQUE,
	scientific_Name VARCHAR(60),
	diet VARCHAR(30) DEFAULT 'Unknown',
	natural_Habitat VARCHAR(40),

	CONSTRAINT pk_species PRIMARY KEY(species_ID)
);

-- Cage Table
CREATE TABLE Cage
(
	cage_ID INT,
	cage_location VARCHAR(80) NOT NULL,
	size DECIMAL(6,2) CHECK (size > 0),     -- increased precision so bigger numbers can fit
	height DECIMAL(6,2) CHECK (height > 0),
	depth DECIMAL(6,2),
	cage_type CHAR(20) DEFAULT 'standard',
	cage_history VARCHAR(100),

	CONSTRAINT pk_cage PRIMARY KEY(cage_ID)
);

-- Animal Table
CREATE TABLE Animal
(
	animal_ID INT,
	animal_fname VARCHAR(20) NOT NULL,
	animal_lname VARCHAR(20),
	animal_DOB DATE NOT NULL,
	animal_Gender CHAR(1) CHECK(animal_Gender IN('M','F')),  -- fixed 'N' -> 'F'
	animal_Weight DECIMAL(7,2) CHECK (animal_Weight > 0),    -- only widened to stop overflow error
	health_Status VARCHAR(15) DEFAULT 'Healthy',
	species_ID INT NOT NULL,
	cage_ID INT NOT NULL,

	CONSTRAINT pk_animal PRIMARY KEY(animal_ID),
	CONSTRAINT fk_animal FOREIGN KEY (species_ID) REFERENCES Species(species_ID),
	CONSTRAINT fk_cage FOREIGN KEY (cage_ID) REFERENCES Cage(cage_ID)
);

-- Employee Table
CREATE TABLE Employee
(
	TRN INT,
	first_name VARCHAR(20) NOT NULL,
	last_name VARCHAR(20) NOT NULL,
	DOB DATE NOT NULL,
	age AS (DATEDIFF(YEAR, DOB, GETDATE())), -- Derived
	date_Employed DATE NOT NULL,
	Employee_Address VARCHAR(80),
	Employee_Role VARCHAR(30) DEFAULT 'staff',
	mobile_Number VARCHAR(10) UNIQUE,

	CONSTRAINT pk_employee PRIMARY KEY(TRN),
	CONSTRAINT chck_age CHECK (DATEDIFF(YEAR, DOB, GETDATE()) >=18)
);

-- Payroll Table
CREATE TABLE Payroll
(
	TRN INT NOT NULL,
	payroll_Number INT NOT NULL,
	hours_Worked DECIMAL(6,2) CHECK (hours_Worked > 0),
	cost_perHour DECIMAL(6,2) DEFAULT 1000 CHECK (cost_perHour >= 500),
	amount_Paid AS (hours_Worked * cost_perHour),
	payroll_Date DATE,

	CONSTRAINT pk_payroll PRIMARY KEY (TRN, payroll_Number),  -- added to prevent duplicate key error
	CONSTRAINT fk_employee FOREIGN KEY (TRN) REFERENCES Employee(TRN)
);
--------------------------------

-- Email Table
CREATE TABLE Email
(
    TRN    INT NOT NULL,
    handle VARCHAR(30) NOT NULL,
    domain VARCHAR(30) NOT NULL,
    suffix VARCHAR(10) NOT NULL,

    CONSTRAINT PK_Email PRIMARY KEY (handle, domain, suffix),
    CONSTRAINT FK_Email_Employee FOREIGN KEY (TRN) REFERENCES Employee(TRN)
);

-- Assigned_To Table
CREATE TABLE Assigned_To
(
    TRN INT NOT NULL,
    cage_ID INT NOT NULL,
    assigned_date DATE DEFAULT GETDATE(),

    CONSTRAINT PK_Assigned_To PRIMARY KEY (TRN, cage_ID),
    CONSTRAINT FK_Assigned_To_Employee FOREIGN KEY (TRN) REFERENCES Employee(TRN),
    CONSTRAINT FK_Assigned_To_Cage FOREIGN KEY (cage_ID) REFERENCES Cage(cage_ID)
);

-- Loading Table
CREATE TABLE Loading
(
    TRN INT NOT NULL,
    animal_ID INT NOT NULL,
    load_date DATE DEFAULT GETDATE(),

    CONSTRAINT PK_Loading PRIMARY KEY (TRN, animal_ID),
    CONSTRAINT FK_Loading_Employee FOREIGN KEY (TRN) REFERENCES Employee(TRN),
    CONSTRAINT FK_Loading_Animal FOREIGN KEY (animal_ID) REFERENCES Animal(animal_ID)
);


--------------------------------
-- Altering Table

-- Add new column
ALTER TABLE Animal
ADD animal_Type CHAR(1) CHECK(animal_Type IN('L', 'W')); -- fixed 'L = Land' & 'w = water'

-- Modify data type in a column
ALTER TABLE Cage
ALTER COLUMN cage_type VARCHAR(30);

-- Drop a column
ALTER TABLE Payroll
DROP COLUMN payrole_Date;

-- Add a constraint
ALTER TABLE Animal
ADD CONSTRAINT CK_Animal_Weight_Positive CHECK (animal_Weight > 0);

--------------------------------
-- LAB 2 Implementations
--------------------------------

-- 1. Add feeding cost per animal

ALTER TABLE Animal
ADD feeding_Cost DECIMAL(8,2) NOT NULL DEFAULT 0;

-- 2. Add minimum temperature required per cage

ALTER TABLE Cage
ADD min_Temperature DECIMAL(4,1) NOT NULL DEFAULT 0;


-- 3. Add caretaker assigned to each animal

ALTER TABLE Animal
ADD caretaker_TRN INT NULL;

ALTER TABLE Animal
ADD CONSTRAINT fk_animal_caretaker
    FOREIGN KEY (caretaker_TRN) REFERENCES Employee(TRN);

--------------------------------

-- Data Population

-- Insert into Species
INSERT INTO Species (species_ID, common_Name, scientific_Name, diet, natural_Habitat)
VALUES
(111, 'Lion', 'Panthera leo', 'Carnivore', 'Savannah'),
(222, 'Giraffe', 'Giraffa camelopardalis', 'Herbivore', 'Grassland'),
(333, 'Crocodile', 'Crocodylus niloticus', 'Carnivore', 'Swamp'),
(444, 'Elephant', 'Loxodonta africana', 'Herbivore', 'Savannah');

-- Insert into Cage
INSERT INTO Cage (cage_ID, cage_location, size, height, depth, cage_type, cage_history)
VALUES
(101, 'Sector A - Savannah Habitat', 80.00, 12.00, 25.00, 'Outdoor', 'Built 2023-03-12'),
(102, 'Sector B - Grassland Enclosure', 70.00, 10.00, 20.00, 'Open Field', 'Refurbished 2024-01-10'),
(103, 'Sector C - Reptile House', 40.00, 5.00, 8.00, 'Glass Tank', 'Cleaned 2023-08-22'),
(104, 'Sector D - Elephant Yard', 200.00, 25.00, 30.00, 'Outdoor', 'Expanded 2024-02-18');

-- Insert into Animal
INSERT INTO Animal (animal_ID, animal_fname, animal_lname, animal_DOB, animal_Gender, animal_Weight, health_Status, species_ID, cage_ID)
VALUES
(1001, 'Simba', 'King', '2020-05-15', 'M', 190.50, 'Healthy', 111, 101),
(1002, 'Nala', 'Queen', '2021-07-18', 'F', 130.25, 'Healthy', 333, 101),
(1003, 'Twiggy', 'Neck', '2019-04-12', 'F', 850.00, 'Healthy', 222, 102),
(1004, 'Ellie', 'Trunk', '2015-08-21', 'F', 2500.00, 'Healthy', 444, 104);

-- Insert into Employee
INSERT INTO Employee (TRN, first_name, last_name, DOB, date_Employed, Employee_Address, Employee_Role, mobile_Number)
VALUES
(101223333, 'Ougaba', 'Gray', '2000-10-21', '2022-05-01', 'Kingston', 'Zookeeper', '8765558765'),
(102334444, 'Daeshaun', 'McIntyre', '1998-02-15', '2021-07-10', 'Montego Bay', 'Veterinarian', '8765559821'),
(103445555, 'Javia', 'Clarke', '1999-09-05', '2020-03-22', 'Mandeville', 'Caretaker', '8765557654'),
(104556666, 'Jareel', 'Edwards', '1995-04-11', '2019-06-30', 'Portmore', DEFAULT, '8765553322');

-- Insert into Payroll
INSERT INTO Payroll (TRN, payroll_Number, hours_Worked, cost_perHour, payroll_Date)
VALUES
(101223333, 1001, 160.00, 1200.00, '2025-01-31'),
(102334444, 1002, 140.00, DEFAULT, '2025-02-28'),
(103445555, 1003, 170.00, 1500.00, '2025-01-31'),
(104556666, 1004, 180.00, 800.00, '2025-03-31');

-- Insert into Email
INSERT INTO Email (TRN, handle, domain, suffix)
VALUES
(101223333, 'ougaba.gray', 'utech', '.com'),
(102334444, 'daeshaun.mc', 'utech', 'com'),
(103445555, 'javia.cl', 'utech', 'org'),
(104556666, 'jareel.ed', 'example', 'com');

-- Insert into Assigned_To
INSERT INTO Assigned_To (TRN, cage_ID, assigned_date)
VALUES
(101223333, 101, DEFAULT),
(102334444, 104, '2025-03-01'),
(103445555, 102, '2025-02-15'),
(104556666, 103, DEFAULT);

-- Insert into Loading
INSERT INTO Loading (TRN, animal_ID, load_date)
VALUES
(101223333, 1001, DEFAULT),      
(102334444, 1004, '2025-03-31'), 
(103445555, 1003, '2025-02-20'), 
(104556666, 1002, DEFAULT);      


-----------------------------------
-- View all table data

SELECT * FROM Species;
SELECT * FROM Cage;
SELECT * FROM Animal;
SELECT * FROM Employee;
SELECT * FROM Payroll;
SELECT * FROM Email;
SELECT * FROM Assigned_To;
SELECT * FROM Loading;
----------------------------------
-- LAB 2 IMPLEMENTATIONS
----------------------------------

-- Example: set feeding cost and caretaker for each animal
UPDATE Animal
SET feeding_Cost = 5000.00, caretaker_TRN = 101223333  -- Ougaba, Zookeeper
WHERE animal_ID IN (1001, 1002);

UPDATE Animal
SET feeding_Cost = 6500.00, caretaker_TRN = 103445555  -- Javia, Caretaker
WHERE animal_ID = 1003;

UPDATE Animal
SET feeding_Cost = 9000.00, caretaker_TRN = 104556666  -- Jareel, Staff
WHERE animal_ID = 1004;

-- Example: set minimum temperature per cage
UPDATE Cage
SET min_Temperature = 24.0 WHERE cage_ID = 101; -- Lions
UPDATE Cage
SET min_Temperature = 22.0 WHERE cage_ID = 102; -- Giraffe
UPDATE Cage
SET min_Temperature = 26.0 WHERE cage_ID = 103; -- Crocodile
UPDATE Cage
SET min_Temperature = 23.0 WHERE cage_ID = 104; -- Elephant


-- Update & Delete

-- Update
-- Raising Daeshaun’s hourly cost by 10%
UPDATE Payroll
SET cost_perHour = CAST(cost_perHour * 1.10 AS DECIMAL(6,2))
WHERE TRN = 102334444 AND payroll_Number = 1002;

-- Promoting Ougaba to Senior Zookeeper
UPDATE Employee
SET Employee_Role = 'Senior Zookeeper'
WHERE TRN = 101223333;

-- Delete
-- Delete a Loading
DELETE FROM Loading
WHERE animal_ID = 1002 AND TRN = 104556666;

-- Delete an Email record 
DELETE FROM Email
WHERE TRN = 103445555 AND suffix = 'com';
-----------------------------------------

-------------
--LAB BETA(2)
-------------

-- Aggregation Queries

-- Total amount spent on animal feed for all enclosures
SELECT SUM(feeding_Cost) AS TotalFeedCost
FROM Animal;

SELECT cage_ID,
       SUM(feeding_Cost) AS TotalFeedCostPerCage 
FROM Animal
GROUP BY cage_ID;

-- Number of animals assigned to each caretaker
SELECT e.TRN,
       e.first_name,
       e.last_name,
       e.Employee_Role,
       COUNT(a.animal_ID) AS NumberOfAnimals
FROM Employee e
JOIN Animal a
    ON a.caretaker_TRN = e.TRN
GROUP BY e.TRN, e.first_name, e.last_name, e.Employee_Role;

-- Minimum temperature required for any animal’s habitat
SELECT MIN(min_Temperature) AS MinRequiredTemperature
FROM Cage;

-- Oldest animal age recorded in the zoo (in years)
SELECT MAX(DATEDIFF(YEAR, animal_DOB, GETDATE())) AS OldestAnimalAgeYears
FROM Animal;

-- Average feeding cost per animal
SELECT AVG(feeding_Cost) AS AvgFeedingCostPerAnimal
FROM Animal;

-- Patten Matching

-- Employees whose last name starts with 'C'
SELECT TRN, first_name, last_name
FROM Employee
WHERE last_name LIKE 'C%';

-- Animals whose first name has 'g' as the 3rd character
SELECT animal_ID, animal_fname, animal_lname
FROM Animal
WHERE animal_fname LIKE '__g%';

-- Sorting

-- Employees sorted by role, then last name descending
SELECT TRN, first_name, last_name, Employee_Role, date_Employed
FROM Employee
ORDER BY Employee_Role ASC, last_name DESC;
-------------------------------------------

--  Calculated Field

-- Show amount paid as hours_Worked * cost_perHour
SELECT TRN,
       payroll_Number,
       hours_Worked,
       cost_perHour,
       hours_Worked * cost_perHour AS CalculatedAmount
FROM Payroll;
-----------------------------------------------------

-- Compound Queries

-- Employees born between two dates 
SELECT TRN, first_name, last_name, DOB
FROM Employee
WHERE DOB BETWEEN '1995-01-01' AND '2001-12-31';

-- Animals that are lions or giraffes using IN
SELECT a.animal_ID, a.animal_fname, s.common_Name
FROM Animal a
JOIN Species s ON a.species_ID = s.species_ID
WHERE s.common_Name IN ('Lion', 'Giraffe');

-- Employees in Kingston OR Montego Bay, and hired after 2020 
SELECT TRN, first_name, last_name, Employee_Address, date_Employed
FROM Employee
WHERE (Employee_Address LIKE '%Kingston%' OR Employee_Address LIKE '%Montego Bay%')
  AND date_Employed >= '2020-01-01';
-----------------------------------------------------

-- DateDiff & DateAdd

-- Duration in days each animal has spent in its current cage
SELECT  a.animal_ID,
        a.animal_fname,
        a.animal_lname,
        c.cage_ID,
        c.cage_location,
        l.load_date,
        DATEDIFF(DAY, l.load_date, GETDATE()) AS DaysInCage
FROM    Animal  a
JOIN    Loading l ON a.animal_ID = l.animal_ID
JOIN    Cage    c ON a.cage_ID   = c.cage_ID;

-- Employees who will reach retirement age (65) in the next 8 months
SELECT  TRN,
        first_name,
        last_name,
        DOB,
        DATEADD(YEAR, 65, DOB) AS retirement_Date
FROM    Employee
WHERE   DATEADD(YEAR, 65, DOB)
        BETWEEN GETDATE() AND DATEADD(MONTH, 8, GETDATE());
---------------------------------------------------------------
-- LAB GAMMA: SCENARIO 3 
-- Student: Ougaba Gray (2405837)
----------------------------------------------------------------
USE JamaicaZoo2405837;
GO


-- i) INNER JOIN: Display Animal, Species, Cage, and Loading Employee
SELECT 
    a.animal_fname + ' ' + ISNULL(a.animal_lname, '') AS Animal_FullName,
    a.animal_Gender,
    a.animal_DOB,
    a.health_Status,
    s.common_Name AS Species_Common_Name,
    s.scientific_Name,
    s.diet,
    c.cage_ID,
    c.cage_location,
    c.cage_type,
    e.first_name + ' ' + e.last_name AS Employee_Loaded_By,
    e.Employee_Role
FROM Animal a
INNER JOIN Species s ON a.species_ID = s.species_ID
INNER JOIN Cage c ON a.cage_ID = c.cage_ID
INNER JOIN Loading l ON a.animal_ID = l.animal_ID
INNER JOIN Employee e ON l.TRN = e.TRN;


-- ii) LEFT JOIN: Employees not assigned to any cage
SELECT 
    e.first_name + ' ' + e.last_name AS Full_Name,
    e.Employee_Role,
    e.age,
    e.Employee_Address,
    e.mobile_Number
FROM Employee e
LEFT JOIN Assigned_To at ON e.TRN = at.TRN
WHERE at.cage_ID IS NULL
ORDER BY e.age DESC;

-- iii) RIGHT JOIN: Cages that have never housed an animal
SELECT 
    c.cage_ID,
    c.cage_location,
    c.cage_type,
    c.size,
    c.height,
    c.depth
FROM Animal a
RIGHT JOIN Cage c
    ON a.cage_ID = c.cage_ID
WHERE a.animal_ID IS NULL;


-- iv) Subqueries and Joins: Animals with completed cage stay
DECLARE @ExpectedDays INT = 30;

SELECT 
    a.animal_fname + ' ' + ISNULL(a.animal_lname, '') AS Animal_Name,
    s.common_Name AS Species,
    c.cage_ID,
    DATEDIFF(DAY, l.load_date, GETDATE()) AS Duration_Days,
    e.first_name + ' ' + e.last_name AS Loader_Name,
    e.Employee_Role,
    DATEDIFF(YEAR, e.date_Employed, GETDATE()) AS Loader_Years_Employed
FROM Animal a
JOIN Species s  ON a.species_ID = s.species_ID
JOIN Cage c     ON a.cage_ID    = c.cage_ID
JOIN Loading l  ON a.animal_ID  = l.animal_ID
JOIN Employee e ON l.TRN        = e.TRN
WHERE DATEDIFF(DAY, l.load_date, GETDATE()) >= @ExpectedDays
  AND a.animal_ID IN (
        SELECT DISTINCT a2.animal_ID
        FROM Animal a2
        JOIN Loading l2 ON a2.animal_ID = l2.animal_ID
        WHERE DATEDIFF(DAY, l2.load_date, GETDATE()) >= @ExpectedDays
     );


-- v) Subquery and IN statement: Last employee employed
--Gender Assignment
ALTER TABLE Employee
ADD gender CHAR(1) CHECK (gender IN ('M','F'));
UPDATE Employee SET gender = 'M';

UPDATE Employee
SET gender = 'F'
WHERE first_name = 'Javia'
  AND last_name = 'Clarke';

----------------------------------------------------------------
SELECT 
    e.first_name + ' ' + e.last_name AS Full_Name,
    e.age,
    e.date_Employed,
    DATEDIFF(MONTH, e.date_Employed, GETDATE()) AS Months_Employed,
    e.Employee_Address,
    e.gender
FROM Employee e
WHERE e.date_Employed IN (
    SELECT MAX(date_Employed) 
    FROM Employee
);


-- vi) FULL JOIN: Animals and their offspring, species, cage, responsible employee
SELECT 
    COALESCE(
        p.animal_fname + ' ' + ISNULL(p.animal_lname, ''),
        'No parent'
    ) AS Parent_Animal,
    COALESCE(
        c.animal_fname + ' ' + ISNULL(c.animal_lname, ''),
        'No offspring'
    ) AS Offspring_Animal,
    s.common_Name AS Species,
    cg.cage_ID,
    cg.cage_type,
    e.first_name + ' ' + e.last_name AS Responsible_Employee,
    e.Employee_Role
FROM Animal p
FULL OUTER JOIN Animal c
    ON p.species_ID = c.species_ID
   AND p.animal_ID <> c.animal_ID
   AND p.animal_DOB < c.animal_DOB    -- parent older than offspring
LEFT JOIN Species s
    ON COALESCE(c.species_ID, p.species_ID) = s.species_ID
LEFT JOIN Cage cg
    ON COALESCE(c.cage_ID, p.cage_ID) = cg.cage_ID
LEFT JOIN Assigned_To at
    ON cg.cage_ID = at.cage_ID
LEFT JOIN Employee e
    ON at.TRN = e.TRN;


-- vii) VIEW: Employee Salary Potential
GO
CREATE VIEW vw_Employee_Details_And_Salary AS
SELECT 
    e.first_name + ' ' + e.last_name AS Full_Name,
    e.age,
    DATEDIFF(YEAR, e.date_Employed, GETDATE()) AS Years_Of_Employment,
    CASE 
        WHEN (65 - e.age) < 0 THEN 0
        ELSE 65 - e.age
    END AS Years_To_Retirement,
    e.gender,
    p.cost_perHour,
    p.hours_Worked,
    CASE 
        WHEN p.hours_Worked <= 40 THEN (p.hours_Worked * p.cost_perHour)
        ELSE (40 * p.cost_perHour) + ((p.hours_Worked - 40) * (p.cost_perHour * 2))
    END AS Potential_Salary
FROM Employee e
JOIN Payroll p ON e.TRN = p.TRN;
GO

-- Verify the View
SELECT * FROM vw_Employee_Details_And_Salary;
