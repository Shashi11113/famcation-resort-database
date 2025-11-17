-- HW5 - FamCation
-- Practice with SELECT INTO, UPDATE, DELETE, date filters, pagination, and basic calculations.

USE FamCation;
GO

------------------------------------------------------------
-- Q1: Copy condos from building 3 into a working table
------------------------------------------------------------
SELECT *
INTO New_Condo_A
FROM CONDO
WHERE BldgNum = 3;

SELECT *
FROM New_Condo_A;

------------------------------------------------------------
-- Q2: Raise daily rate and square footage for 3-bedroom units
--     then display specific units.
------------------------------------------------------------
UPDATE New_Condo_A
SET DailyRate = DailyRate * 1.20,
    SqrFt     = SqrFt + 250
WHERE Bdrms = 3;

SELECT *
FROM New_Condo_A
WHERE UnitNum IN ('105', '205', '305');

------------------------------------------------------------
-- Q3: Delete 2-bedroom condos above a certain daily rate
--     and show remaining 2-bedroom units.
------------------------------------------------------------
DELETE
FROM New_Condo_A
WHERE Bdrms    = 2
  AND DailyRate > 130;

SELECT *
FROM New_Condo_A
WHERE Bdrms = 2;

------------------------------------------------------------
-- Q4: Find guides whose renewal is at least 732 days
--     after certification.
------------------------------------------------------------
SELECT
    GuideID,
    CertDate,
    CertRenewDate
FROM GUIDE
WHERE DATEDIFF(DAY, CertDate, CertRenewDate) >= 732;

------------------------------------------------------------
-- Q5: List the 3 earliest-hired employees.
------------------------------------------------------------
SELECT TOP 3
    EmpID                         AS 'Employee ID',
    CONCAT(FName, '', LName)      AS 'Employee Name',
    HireDate                      AS 'Hire Date'
FROM EMPLOYEE
ORDER BY HireDate;

------------------------------------------------------------
-- Q6: Guests who booked in Building A in May 2021.
------------------------------------------------------------
SELECT
    GuestID AS 'Guest ID'
FROM BOOKING
WHERE BldgNum         = 'A'
  AND YEAR(StartDate)  = 2021
  AND MONTH(StartDate) = 5
ORDER BY YEAR(StartDate);

------------------------------------------------------------
-- Q7: Paginate reservations:
--     Skip the first 20 rows and return the next 10.
------------------------------------------------------------
SELECT *
FROM RESERVATION
ORDER BY RDate DESC
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY;

------------------------------------------------------------
-- Q8: Show monthly salary in different formats for Marketing.
------------------------------------------------------------
SELECT
    EmpID                                   AS 'Employee ID',
    Department,
    Salary / 12                             AS 'Monthly Salary',
    CAST(Salary / 12 AS DECIMAL(10, 2))     AS 'Monthly Salary in Decimal',
    CAST(ROUND(Salary / 12, 0) AS INT)      AS 'Monthly Salary in Integer'
FROM EMPLOYEE
WHERE Department = 'Marketing';

------------------------------------------------------------
-- Q9: List river activities within distance 10–20,
--     ordered by hours and distance descending.
------------------------------------------------------------
SELECT *
FROM ACTIVITY
WHERE Description LIKE '%River%'
  AND Distance BETWEEN 10 AND 20
ORDER BY Hours DESC, Distance DESC;
