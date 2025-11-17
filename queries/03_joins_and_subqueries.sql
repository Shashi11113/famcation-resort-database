-- HW7.1 - FamCation
-- Focus on joins, subqueries, EXISTS/NOT EXISTS, and UNION.

USE FamCation;
GO

------------------------------------------------------------
-- Q1: Temp housekeepers hired after 2018-01-01.
------------------------------------------------------------
SELECT
    e.EmpID,
    e.FName,
    e.LName,
    h.Status,
    h.Shift
FROM EMPLOYEE    AS e
JOIN HOUSEKEEPER AS h
    ON h.HKID = e.EmpID
WHERE e.HireDate > '2018-01-01'
  AND h.Status   = 'Temp';

------------------------------------------------------------
-- Q2: Reservations for guest Montana, guided by Gayle.
------------------------------------------------------------
SELECT
    g.FName + ' ' + g.LName AS 'Guest Name',
    e.FName                  AS 'Guide',
    r.ResID                  AS 'Resid',
    r.RDate,
    r.ActID
FROM GUEST       AS g
INNER JOIN RESERVATION AS r
    ON g.GuestID = r.GuestID
INNER JOIN GUIDE AS g1
    ON r.GuideID = g1.GuideID
INNER JOIN EMPLOYEE AS e
    ON g1.GuideID = e.EmpID
WHERE g.LName = 'Montana'
  AND e.FName = 'Gayle';

------------------------------------------------------------
-- Q3: Activity revenue summary for 2021, top 6 by count.
------------------------------------------------------------
SELECT
    a.ActID                          AS 'Activity ID',
    a.Description,
    COUNT(r.ResID)                   AS 'Reservation Count',
    SUM(r.NumberInParty)             AS 'Total Participant',
    a.PPP,
    SUM(r.NumberInParty * a.PPP)     AS 'Total Activity Amount'
FROM RESERVATION AS r
INNER JOIN ACTIVITY AS a
    ON r.ActID = a.ActID
WHERE YEAR(r.RDate) = 2021
GROUP BY
    a.ActID,
    a.Description,
    a.PPP
ORDER BY COUNT(r.ResID) DESC
OFFSET 0 ROWS
FETCH NEXT 6 ROWS ONLY;

------------------------------------------------------------
-- Q4: Managers with salary above company average.
------------------------------------------------------------
SELECT
    EmpID    AS 'Empid',
    FName + ' ' + LName AS 'Name',
    Salary,
    Department
FROM EMPLOYEE
WHERE EmpID IN (
    SELECT E.EmpID
    FROM EMPLOYEE AS E
    WHERE E.Salary > (SELECT AVG(Salary) FROM EMPLOYEE)
      AND E.EmpID IN (
            SELECT MgrNum
            FROM EMPLOYEE AS M
            WHERE M.MgrNum = E.EmpID
      )
);

------------------------------------------------------------
-- Q5: CA guests with NO children (LEFT JOIN NULL pattern).
------------------------------------------------------------
SELECT
    G.GuestID      AS Guestid,
    G.FName,
    G.LName,
    G.SpouseFName,
    'NULL'         AS Children
FROM GUEST  AS G
LEFT JOIN FAMILY AS F
    ON G.GuestID = F.GuestID
WHERE G.State = 'CA'
  AND F.GuestID IS NULL;

------------------------------------------------------------
-- Q6: Same as Q5 using NOT IN.
------------------------------------------------------------
SELECT
    G.GuestID      AS Guestid,
    G.FName,
    G.LName,
    G.SpouseFName
FROM GUEST AS G
WHERE G.State = 'CA'
  AND G.GuestID NOT IN (
        SELECT GuestID
        FROM FAMILY
  );

------------------------------------------------------------
-- Q7: Same as Q5 using NOT EXISTS.
------------------------------------------------------------
SELECT
    G.GuestID      AS Guestid,
    G.FName,
    G.LName,
    G.SpouseFName
FROM GUEST AS G
WHERE G.State = 'CA'
  AND NOT EXISTS (
        SELECT *
        FROM FAMILY AS F
        WHERE F.GuestID = G.GuestID
  );

------------------------------------------------------------
-- Q8: Specific guests with 2022 bookings in C-building
--     2-bedroom units starting with '3'.
------------------------------------------------------------
SELECT
    B.GuestID,
    MIN(B.StartDate) AS StartDate,
    MAX(B.EndDate)   AS EndDate,
    B.UnitNum
FROM BOOKING AS B
WHERE B.GuestID IN ('G14', 'G17', 'G23')
  AND B.UnitNum IN (
        SELECT UnitNum
        FROM CONDO
        WHERE BldgNum = 'C'
          AND UnitNum LIKE '3%'
          AND Bdrms = 2
  )
  AND YEAR(B.StartDate) = 2022
GROUP BY
    B.GuestID,
    B.UnitNum
ORDER BY B.GuestID;

------------------------------------------------------------
-- Q9: Reservation counts for employees, plus NULL bucket
--     for reservations with no employee assigned.
------------------------------------------------------------
SELECT
    e.EmpID                         AS ID,
    e.FName + ' ' + e.LName         AS Name,
    COUNT(r.ResID)                  AS "Reservation Count"
FROM Employee   AS e
LEFT JOIN Reservation AS r
    ON e.EmpID = r.EmpID
   AND YEAR(r.RDate) = 2023
GROUP BY
    e.EmpID,
    e.FName,
    e.LName
HAVING COUNT(r.ResID) > 0

UNION ALL

SELECT
    NULL                            AS ID,
    NULL                            AS Name,
    COUNT(r.ResID)                  AS "Reservation Count"
FROM Reservation AS r
WHERE r.EmpID IS NULL
  AND YEAR(r.RDate) = 2023
ORDER BY Name;

------------------------------------------------------------
-- Q10: Employees in Operations and their managers.
------------------------------------------------------------
SELECT
    CONCAT(e.FName, ' ', e.LName) AS "Employee Name",
    e.Department,
    e.HireDate                    AS "Hiredate",
    CONCAT(m.FName, ' ', m.LName) AS "Manager Name",
    m.HireDate                    AS "Manager Hiredate"
FROM Employee AS e
JOIN Employee  AS m
    ON e.MgrNum = m.EmpID
WHERE e.Department = 'Operations'
  AND e.EmpID <> m.EmpID
ORDER BY e.EmpID;
