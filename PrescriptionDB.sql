-- Creating the dtabase
CREATE DATABASE PrescriptionDB
--------------------------------
USE PrescriptionDB;
--------------------------------
-- Step 1: After importing the CSV files, I'll go ahead to create tables
CREATE TABLE Medical_Practice (
    PRACTICE_CODE NVARCHAR(50) PRIMARY KEY,
    PRACTICE_NAME NVARCHAR(50) NOT NULL,
    ADDRESS_1 NVARCHAR(50) NOT NULL,
    ADDRESS_2 NVARCHAR(50),
    ADDRESS_3 NVARCHAR(50),
    ADDRESS_4 NVARCHAR(50),
    POSTCODE NVARCHAR(50) NOT NULL,
);

-- Creating the drugs table
CREATE TABLE Drugs (
	BNF_CODE NVARCHAR(100) PRIMARY KEY,
    CHEMICAL_SUBSTANCE_BNF_DESCR NVARCHAR(100) NOT NULL,
    BNF_DESCRIPTION NVARCHAR(100) NOT NULL,
    BNF_CHAPTER_PLUS_CODE NVARCHAR(100),
);

-- Creating the Prescription tables
CREATE TABLE Prescriptions (
    PRESCRIPTION_CODE INT IDENTITY(0,1) PRIMARY KEY,
    PRACTICE_CODE NVARCHAR(50) NOT NULL,
    BNF_CODE NVARCHAR(100) NOT NULL,
    QUANTITY FLOAT NOT NULL,
    ITEMS INT NOT NULL,
    ACTUAL_COST MONEY NOT NULL,
    FOREIGN KEY (PRACTICE_CODE) REFERENCES Medical_Practice(PRACTICE_CODE)
);


-- Step 2; The next step would be to populate the tables with data from the imported files
INSERT INTO Medical_Practice (PRACTICE_CODE, PRACTICE_NAME, ADDRESS_1, ADDRESS_2, ADDRESS_3, ADDRESS_4, POSTCODE)
SELECT PRACTICE_CODE, PRACTICE_NAME, ADDRESS_1, ADDRESS_2, ADDRESS_3, ADDRESS_4, POSTCODE
FROM dbo.Medical_Practice_csv;

-- Inserting into the drugs table
INSERT INTO Drugs (BNF_CODE, CHEMICAL_SUBSTANCE_BNF_DESCR, BNF_DESCRIPTION, BNF_CHAPTER_PLUS_CODE)
SELECT BNF_CODE, CHEMICAL_SUBSTANCE_BNF_DESCR, BNF_DESCRIPTION, BNF_CHAPTER_PLUS_CODE
FROM dbo.Drugs_csv;

-- Inserting into the Prescription table
SET IDENTITY_INSERT dbo.Prescriptions ON;
INSERT INTO Prescriptions (PRESCRIPTION_CODE, PRACTICE_CODE, BNF_CODE, QUANTITY, ITEMS, ACTUAL_COST)
SELECT PRESCRIPTION_CODE, PRACTICE_CODE, BNF_CODE, QUANTITY, ITEMS, ACTUAL_COST
FROM dbo.Prescriptions_csv;


-- Now dropping the CSV files table
DROP TABLE dbo.Medical_Practice_csv;
DROP TABLE dbo.Drugs_csv;
DROP TABLE dbo.Prescriptions_csv;



-- For the Implementation of the Problem queries
-- Querying for drugs in the form of tablets or capsules:
SELECT *
FROM Drugs
WHERE BNF_DESCRIPTION LIKE '%tablet%' OR BNF_DESCRIPTION LIKE '%capsule%';

-- Querying for the total quantity for each prescription:
SELECT PRESCRIPTION_CODE, ROUND(CONVERT(NUMERIC(18,2),QUANTITY) * CONVERT(NUMERIC(18,2),ITEMS), 0) AS TotalQuantity
FROM Prescriptions;

-- Querying for the distinct chemical substances:
SELECT DISTINCT CHEMICAL_SUBSTANCE_BNF_DESCR
FROM Drugs;


-- Querying for the number of prescriptions for each BNF_CHAPTER_PLUS_CODE:
SELECT BNF_CHAPTER_PLUS_CODE, COUNT(*) AS NumPrescriptions, AVG(ACTUAL_COST) AS AvgCost, MIN(ACTUAL_COST) AS MinCost, MAX(ACTUAL_COST) AS MaxCost
FROM Prescriptions
INNER JOIN Drugs ON Prescriptions.BNF_CODE = Drugs.BNF_CODE
GROUP BY BNF_CHAPTER_PLUS_CODE;


-- Most expensive prescription prescribed by eachpractice, sorted in descending order by prescription cost (the ACTUAL_COST column inthe prescription table.)
SELECT p.PRACTICE_NAME, MAX(pr.ACTUAL_COST) AS MAX_COST
FROM Medical_Practice p
INNER JOIN Prescriptions pr ON p.PRACTICE_CODE = pr.PRACTICE_CODE
GROUP BY p.PRACTICE_NAME
HAVING MAX(pr.ACTUAL_COST) > 4000
ORDER BY MAX_COST DESC;



-- 5 Additional codes for implementation
-- Query to return the total quantity of each drug prescribed:
SELECT d.BNF_DESCRIPTION, SUM(CAST(p.ITEMS AS decimal(18, 10)) * CAST(p.QUANTITY AS decimal(18, 10))) AS TOTAL_QUANTITY
FROM Drugs d
INNER JOIN Prescriptions p ON d.BNF_CODE = p.BNF_CODE
GROUP BY d.BNF_DESCRIPTION;


-- Query to return the average cost of prescriptions for each practice:
SELECT p.PRACTICE_NAME, AVG(pr.ACTUAL_COST) AS AVG_COST
FROM Medical_Practice p
INNER JOIN Prescriptions pr ON p.PRACTICE_CODE = pr.PRACTICE_CODE
GROUP BY p.PRACTICE_NAME;

-- Query to return the number of prescriptions for each BNF chapter code:
SELECT d.BNF_CHAPTER_PLUS_CODE, COUNT(*) AS NUM_PRESCRIPTIONS
FROM Drugs d
INNER JOIN Prescriptions p ON d.BNF_CODE = p.BNF_CODE
GROUP BY d.BNF_CHAPTER_PLUS_CODE;

-- Query to return the average cost of prescriptions for each BNF chapter code:
SELECT d.BNF_CHAPTER_PLUS_CODE, AVG(pr.ACTUAL_COST) AS AVG_COST
FROM Drugs d
INNER JOIN Prescriptions pr ON d.BNF_CODE = pr.BNF_CODE
GROUP BY d.BNF_CHAPTER_PLUS_CODE;


-- Query to return the total cost of prescriptions for each practice:
SELECT Medical_Practice.PRACTICE_NAME, SUM(Prescriptions.ACTUAL_COST) AS TOTAL_COST
FROM Medical_Practice
JOIN Prescriptions ON Medical_Practice.PRACTICE_CODE = Prescriptions.PRACTICE_CODE
GROUP BY Medical_Practice.PRACTICE_NAME
ORDER BY TOTAL_COST DESC;




