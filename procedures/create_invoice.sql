USE FamCation;
GO

IF OBJECT_ID('dbo.INVOICE_TEMP','U') IS NULL
BEGIN
    CREATE TABLE dbo.INVOICE_TEMP (
        InvoiceID   int IDENTITY(1,1) PRIMARY KEY,
        GuestID     varchar(4) NOT NULL,
        BookID      int        NOT NULL,
        StartDate   date       NOT NULL,
        EndDate     date       NOT NULL,
        CondoFee    decimal(10,2) NOT NULL,
        ActivityFee decimal(10,2) NOT NULL,
        InvoiceTotal decimal(10,2) NOT NULL
    );
END
GO

USE FamCation;
GO

IF OBJECT_ID('dbo.Create_Invoice','P') IS NOT NULL
    DROP PROCEDURE dbo.Create_Invoice;
GO

CREATE PROCEDURE dbo.Create_Invoice
    @GuestID   varchar(4),
    @StartDate date,
    @EndDate   date
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BookID int;
        DECLARE @CondoFee decimal(10,2);
        DECLARE @ActivityFee decimal(10,2);

        SELECT @BookID = BookID
        FROM dbo.BOOKING
        WHERE GuestID = @GuestID
          AND StartDate = @StartDate;

        -- Condo fee: nights * daily rate
        SELECT @CondoFee = DATEDIFF(DAY, B.StartDate, B.EndDate) * C.DailyRate
        FROM dbo.BOOKING B
        JOIN dbo.CONDO C
          ON B.BldgNum = C.BldgNum
         AND B.UnitNum = C.UnitNum
        WHERE B.GuestID = @GuestID
          AND B.StartDate = @StartDate;

        -- Activity fee: sum over all activities in date range
        SELECT @ActivityFee = ISNULL(SUM(R.NumberInParty * A.PPP),0.00)
        FROM dbo.RESERVATION R
        JOIN dbo.ACTIVITY A ON R.ActID = A.ActID
        WHERE R.GuestID = @GuestID
          AND R.RDate BETWEEN @StartDate AND @EndDate;

        IF @BookID IS NULL
        BEGIN
            RAISERROR('No booking found for @GuestID and @StartDate.', 16, 1);
        END

        INSERT INTO dbo.INVOICE_TEMP (GuestID, BookID, StartDate, EndDate, CondoFee, ActivityFee, InvoiceTotal)
        SELECT @GuestID,
               @BookID,
               @StartDate,
               @EndDate,
               ISNULL(@CondoFee,0.00),
               ISNULL(@ActivityFee,0.00),
               ISNULL(@CondoFee,0.00) + ISNULL(@ActivityFee,0.00);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        DECLARE @ErrorNumber int = ERROR_NUMBER(),
                @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();

        RAISERROR('Create_Invoice failed. %d - %s', 16, 1, @ErrorNumber, @ErrorMessage);
    END CATCH
END
GO
