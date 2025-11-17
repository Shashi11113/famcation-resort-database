-- HW7.2 - FamCation
-- UNION, views, CTEs, ranking/window functions.

USE FamCation;
GO

------------------------------------------------------------
-- Q1: Highest, lowest, and average daily rates per building.
------------------------------------------------------------
SELECT
    'Highest Daily Rate' AS Category,
    'A'                  AS 'Building Number',
    CAST(MAX(DailyRate) AS INT) AS DailyRate
FROM CONDO
WHERE BldgNum = 'A'

UNION ALL

SELECT
    'Lowest Daily Rate'  AS Category,
    'B'                  AS 'Building Number',
    CAST(MIN(DailyRate) AS INT) AS DailyRate
FROM CONDO
WHERE BldgNum = 'B'

UNION ALL

SELECT
    'Average Daily Rate' AS Category,
    'C'                  AS 'Building Number',
    CAST(AVG(DailyRate) AS INT) AS DailyRate
FROM CONDO
WHERE BldgNum = 'C'
ORDER BY [Building Number];
------------------------------------------------------------
-- Q2: View of top 3 housekeepers in Aug 2021 by number
--     of cleaning schedules.
------------------------------------------------------------
CREATE VIEW Top_Housekeeper_View
AS
SELECT TOP 3
    HKID,
    COUNT(*) AS "Total Schedule"
FROM CLEANING
WHERE MONTH(DateCleaned) = 8
  AND YEAR(DateCleaned)  = 2021
GROUP BY HKID
ORDER BY "Total Schedule" DESC;
GO

SELECT *
FROM Top_Housekeeper_View;
GO

------------------------------------------------------------
-- Q3: Join view with employees and managers.
------------------------------------------------------------
SELECT
    e.EmpID,
    e.HireDate,
    e.FName + ' ' + e.LName AS Housekeeper,
    m.FName + ' ' + m.LName AS Manager
FROM Top_Housekeeper_View AS T
INNER JOIN Employee AS e
    ON T.HKID = e.EmpID
LEFT JOIN Employee  AS m
    ON e.MgrNum = m.EmpID
ORDER BY 4;

------------------------------------------------------------
-- Q4: Same as Q3 using a CTE.
------------------------------------------------------------
WITH Top_Housekeeper_CTE AS (
    SELECT TOP 3
        HKID,
        COUNT(*) AS TotalSchedule
    FROM Cleaning
    WHERE MONTH(DateCleaned) = 8
      AND YEAR(DateCleaned)  = 2021
    GROUP BY HKID
    ORDER BY TotalSchedule DESC
)
SELECT
    e.EmpID,
    e.HireDate,
    e.FName + ' ' + e.LName AS Housekeeper,
    m.FName + ' ' + m.LName AS Manager
FROM Top_Housekeeper_CTE AS thc
INNER JOIN Employee AS e
    ON thc.HKID = e.EmpID
LEFT JOIN Employee  AS m
    ON e.MgrNum = m.EmpID
ORDER BY 4;

------------------------------------------------------------
-- Q5: Same as Q3 using a subquery instead of a CTE/view.
------------------------------------------------------------
SELECT
    e.EmpID,
    e.HireDate,
    e.FName + ' ' + e.LName AS Housekeeper,
    m.FName + ' ' + m.LName AS Manager
FROM (
    SELECT TOP 3
        HKID,
        COUNT(*) AS TotalSchedule
    FROM Cleaning
    WHERE MONTH(DateCleaned) = 8
      AND YEAR(DateCleaned)  = 2021
    GROUP BY HKID
    ORDER BY TotalSchedule DESC
) AS top_hk
INNER JOIN Employee AS e
    ON top_hk.HKID = e.EmpID
LEFT JOIN Employee  AS m
    ON e.MgrNum = m.EmpID
ORDER BY 4;

------------------------------------------------------------
-- Q6: Top 1 housekeeper by tasks and top 2 guides by tasks,
--     combined with UNION ALL.
------------------------------------------------------------
WITH Housekeeper AS (
    SELECT TOP 1
        'Housekeeper' AS Position,
        HKID          AS EmployeeID,
        COUNT(*)      AS TaskCount
    FROM Cleaning
    GROUP BY HKID
    ORDER BY TaskCount DESC
),
Guide AS (
    SELECT TOP 2
        'Guide'   AS Position,
        GuideID   AS EmployeeID,
        COUNT(*)  AS TaskCount
    FROM Reservation
    GROUP BY GuideID
    ORDER BY TaskCount DESC
)
SELECT
    Position,
    EmployeeID,
    TaskCount
FROM Housekeeper

UNION ALL

SELECT
    Position,
    EmployeeID,
    TaskCount
FROM Guide;

------------------------------------------------------------
-- Q7: Most recent reservation per employee (ROW_NUMBER).
------------------------------------------------------------
WITH RecentReserves AS (
    SELECT
        r.EmpID,
        a.Description,
        r.RDate,
        ROW_NUMBER() OVER (
            PARTITION BY r.EmpID
            ORDER BY r.RDate DESC
        ) AS RN
    FROM Reservation AS r
    INNER JOIN Activity AS a
        ON r.ActID = a.ActID
    WHERE r.EmpID IS NOT NULL
)
SELECT
    EmpID,
    Description,
    RDate
FROM RecentReserves
WHERE RN = 1
ORDER BY EmpID;

------------------------------------------------------------
-- Q8: Shortest-distance reservation per employee (RANK).
------------------------------------------------------------
WITH ShortDistanceReservations AS (
    SELECT
        R.EmpID,
        A.ActID,
        A.Description,
        R.RDate,
        A.Distance,
        RANK() OVER (
            PARTITION BY R.EmpID
            ORDER BY A.Distance
        ) AS RankNo
    FROM Reservation AS R
    INNER JOIN Activity AS A
        ON R.ActID = A.ActID
    WHERE R.EmpID IS NOT NULL
)
SELECT
    EmpID,
    ActID,
    Description,
    RDate,
    Distance
FROM ShortDistanceReservations
WHERE RankNo = 1
ORDER BY EmpID;
