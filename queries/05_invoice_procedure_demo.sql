-- HW8 - FamCation
-- Invoice / stored procedure practice.

USE FamCation;
GO

------------------------------------------------------------
-- Q1: Get the booking ID for guest G5 starting 2023-08-01.
------------------------------------------------------------
SELECT
    BookID
FROM BOOKING
WHERE GuestID  = 'G5'
  AND StartDate = '2023-08-01';

------------------------------------------------------------
-- Q2: Condo fee for that stay.
------------------------------------------------------------
SELECT
    DATEDIFF(DAY, B.StartDate, B.EndDate) * C.DailyRate AS TotalCondoFee
FROM BOOKING AS B
INNER JOIN CONDO  AS C
    ON B.BldgNum = C.BldgNum
   AND B.UnitNum = C.UnitNum
WHERE B.GuestID  = 'G5'
  AND B.StartDate = '2023-08-01';

------------------------------------------------------------
-- Q3: Activity fee over the stay window for guest G5.
------------------------------------------------------------
SELECT
    R.NumberInParty * A.PPP AS ActivityFee
FROM RESERVATION AS R
INNER JOIN ACTIVITY   AS A
    ON R.ActID = A.ActID
WHERE R.GuestID = 'G5'
  AND R.RDate BETWEEN '2023-08-01' AND '2023-08-20';

------------------------------------------------------------
-- Q4: Create stored procedure Create_Invoice.
------------------------------------------------------------
CREATE PROCEDURE Create_Invoice
    @GuestID   VARCHAR(4),
    @StartDate DATE,
    @EndDate   DATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BookID      INT;
        DECLARE @CondoFee    DECIMAL(7, 2);
        DECLARE @ActivityFee DECIMAL(7, 2);

        -- Find the booking row
        SELECT @BookID = BookID
        FROM BOOKING
        WHERE GuestID  = @GuestID
          AND StartDate = @StartDate;

        -- Calculate condo fee
        SELECT @CondoFee =
            DATEDIFF(DAY, B.StartDate, B.EndDate) * C.DailyRate
        FROM BOOKING AS B
        INNER JOIN CONDO AS C
            ON B.BldgNum = C.BldgNum
           AND B.UnitNum = C.UnitNum
        WHERE B.GuestID  = @GuestID
          AND B.StartDate = @StartDate;

        -- Calculate activity fee (NOTE: takes only one row as written in HW)
        SELECT @ActivityFee =
            R.NumberInParty * A.PPP
        FROM RESERVATION AS R
        INNER JOIN ACTIVITY   AS A
            ON R.ActID = A.ActID
        WHERE R.GuestID = @GuestID
          AND R.RDate BETWEEN @StartDate AND @EndDate;

        -- Insert invoice row
        INSERT INTO INVOICE
            (BookID, GuestID, StartDate, EndDate, CondoFee, ActivityFee)
        VALUES
            (@BookID, @GuestID, @StartDate, @EndDate, @CondoFee, @ActivityFee);

        -- Update totals
        UPDATE INVOICE
        SET InvoiceTotal = @CondoFee + @ActivityFee,
            SalesTax     = (@CondoFee + @ActivityFee) * 0.09,
            GrandTotal   = (@CondoFee + @ActivityFee) * 1.09
        WHERE InvoiceID = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT
            ERROR_NUMBER()  AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO

------------------------------------------------------------
-- Q5: Execute the procedure and see the invoice row.
------------------------------------------------------------
EXEC Create_Invoice
    @GuestID   = 'G5',
    @StartDate = '2023-08-01',
    @EndDate   = '2023-08-20';

SELECT *
FROM INVOICE;
