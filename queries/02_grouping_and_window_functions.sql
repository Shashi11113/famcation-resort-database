-- HW6 - FamCation
-- Practice with aggregates, GROUP BY, HAVING, and window functions.

USE FamCation;
GO

------------------------------------------------------------
-- Q1: Horseback reservations in 2021
--     excluding two specific guides.
------------------------------------------------------------
SELECT
    ResID,
    GuestID,
    EmpID,
    ActID,
    GuideID,
    RDate,
    NumberInParty
FROM RESERVATION
WHERE ActID LIKE 'HB%'
  AND YEAR(RDate) = 2021
  AND GuideID NOT IN ('RH01', 'MR01');

------------------------------------------------------------
-- Q2: Most, least, and average employee years of service.
------------------------------------------------------------
SELECT
    MAX(DATEDIFF(YEAR, HireDate, GETDATE()))        AS 'Most Years',
    MIN(DATEDIFF(YEAR, HireDate, GETDATE()))        AS 'Least Years',
    FLOOR(AVG(DATEDIFF(YEAR, HireDate, GETDATE()))) AS 'Average Years'
FROM EMPLOYEE;

------------------------------------------------------------
-- Q3: Condos that match specific building + bedroom + rate criteria.
------------------------------------------------------------
SELECT *
FROM CONDO
WHERE (Bdrms = 2 AND BldgNum = 'C' AND [Daily Rate] > 130)
   OR (Bdrms = 3 AND BldgNum = 'B' AND [Daily Rate] > 145);

------------------------------------------------------------
-- Q4: Average daily rate by building.
------------------------------------------------------------
SELECT
    BldgNum,
    CAST(AVG([Daily Rate]) AS INT) AS [Average Daily Rate]
FROM CONDO
GROUP BY BldgNum;

------------------------------------------------------------
-- Q5: Guests with more than 5 visits in a year.
------------------------------------------------------------
SELECT
    GuestID,
    YEAR(StartDate) AS [Year],
    COUNT(*)        AS [No of Visits]
FROM BOOKING
GROUP BY
    GuestID,
    YEAR(StartDate)
HAVING COUNT(*) > 5
ORDER BY [Year] ASC;

------------------------------------------------------------
-- Q6: Exactly identical bookings (duplicate rows).
------------------------------------------------------------
SELECT
    GuestID,
    BldgNum,
    UnitNum,
    StartDate,
    EndDate,
    COUNT(*) AS [No of Visits]
FROM BOOKING
GROUP BY
    GuestID,
    BldgNum,
    UnitNum,
    StartDate,
    EndDate
HAVING COUNT(*) > 1;

------------------------------------------------------------
-- Q7: Top 4 activities by reservation count, ties included.
------------------------------------------------------------
SELECT TOP 4 WITH TIES
    ActID                 AS [Activity ID],
    COUNT(ResID)          AS [Reservation Count],
    SUM(NumberInParty)    AS [Party Count]
FROM RESERVATION
WHERE YEAR(RDate) = 2021
GROUP BY ActID
ORDER BY [Reservation Count] DESC,
         [Party Count]      DESC;

------------------------------------------------------------
-- Q8: Horseback activities in 2021 with total party count
--     and reservation count.
------------------------------------------------------------
SELECT
    ActID,
    SUM(NumberInParty) AS [Party Count],
    COUNT(ResID)       AS [Reservation Count]
FROM RESERVATION
WHERE YEAR(RDate) = 2021
  AND ActID LIKE 'HB%'
GROUP BY ActID
ORDER BY ActID;

------------------------------------------------------------
-- Q9: same as Q8 but using window functions per activity.
------------------------------------------------------------
SELECT
    ActID,
    GuestID,
    GuideID,
    SUM(NumberInParty) OVER (PARTITION BY ActID) AS [Party Count],
    COUNT(ResID)       OVER (PARTITION BY ActID) AS [Reservation Count]
FROM RESERVATION
WHERE YEAR(RDate) = 2021
  AND ActID LIKE 'HB%'
ORDER BY ActID, GuestID;

------------------------------------------------------------
-- Q10: Window functions per guide.
------------------------------------------------------------
SELECT
    GuideID,
    ActID,
    GuestID,
    SUM(NumberInParty) OVER (PARTITION BY GuideID) AS [Party Count],
    COUNT(ResID)       OVER (PARTITION BY GuideID) AS [Reservation Count]
FROM RESERVATION
WHERE YEAR(RDate) = 2021
  AND ActID LIKE 'HB%'
ORDER BY GuideID, ActID, GuestID;

------------------------------------------------------------
-- Q11: Monthly reservation count per activity in 2021.
------------------------------------------------------------
SELECT
    MONTH(RDate) AS [Month],
    ActID,
    GuestID,
    RDate,
    COUNT(ResID) OVER (PARTITION BY MONTH(RDate), ActID) AS [Reservation Count]
FROM RESERVATION
WHERE YEAR(RDate) = 2021
  AND ActID LIKE 'HB%'
ORDER BY [Month], ActID, GuestID, RDate;

------------------------------------------------------------
-- Q12: Lowest, highest, and average daily rates per building.
--      (Note: uses BuildingNumber and DailyRate as in original HW.)
------------------------------------------------------------
SELECT
    CASE
        WHEN BuildingNumber = 'A' THEN 'Lowest Daily Rate'
        WHEN BuildingNumber = 'B' THEN 'Highest Daily Rate'
        WHEN BuildingNumber = 'C' THEN 'Average Daily Rate'
        ELSE NULL
    END               AS Category,
    BuildingNumber    AS [Building Number],
    CAST(DailyRate AS INT) AS [Daily Rate]
FROM (
    SELECT
        BuildingNumber,
        CASE
            WHEN BuildingNumber = 'A' THEN MIN(DailyRate)
            WHEN BuildingNumber = 'B' THEN MAX(DailyRate)
            WHEN BuildingNumber = 'C' THEN AVG(DailyRate)
            ELSE NULL
        END AS DailyRate
    FROM CONDO
    GROUP BY BuildingNumber
) AS Rates;

------------------------------------------------------------
-- Q13: Copy activities and adjust hours/prices/distances
--      based on type, using CASE statements.
------------------------------------------------------------

-- Step 1: Create New_Activity table as a copy of Activity
SELECT *
INTO New_Activity
FROM Activity;

-- Step 2: Display activities meeting specified criteria
SELECT *
FROM New_Activity
WHERE (Type = 'Bike'  AND Hours = 4)
   OR (Type = 'Hike'  AND PPP   = 10.00)
   OR  Type = 'Horseback';

-- Step 3: Update Hours, PPP, and Distance using CASE
UPDATE New_Activity
SET Hours = CASE
                WHEN Type = 'Bike' AND Hours = 4 THEN 6
                ELSE Hours
            END,
    PPP = CASE
              WHEN Type = 'Hike' AND PPP = 10.00 THEN 12.00
              ELSE PPP
          END,
    Distance = CASE
                   WHEN Type = 'Horseback' THEN Distance + 2
                   ELSE Distance
               END;

-- Step 4: Display updated biking, hiking, and horseback rows
SELECT *
FROM New_Activity
WHERE Type IN ('Bike', 'Hike', 'Horseback');
