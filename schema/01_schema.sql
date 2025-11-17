-- FamCation Database Schema (SQL Server)
-- This is a cleaned, portfolio-friendly schema that matches the FamCation scenario.

IF DB_ID('FamCation') IS NULL
BEGIN
    EXEC('CREATE DATABASE FamCation');
END
GO

USE FamCation;
GO

-- Drop in FK‑safe order
IF OBJECT_ID('dbo.RESERVATION','U') IS NOT NULL DROP TABLE dbo.RESERVATION;
IF OBJECT_ID('dbo.CLEANING','U')    IS NOT NULL DROP TABLE dbo.CLEANING;
IF OBJECT_ID('dbo.BOOKING','U')     IS NOT NULL DROP TABLE dbo.BOOKING;
IF OBJECT_ID('dbo.FAMILY','U')      IS NOT NULL DROP TABLE dbo.FAMILY;
IF OBJECT_ID('dbo.HOUSEKEEPER','U') IS NOT NULL DROP TABLE dbo.HOUSEKEEPER;
IF OBJECT_ID('dbo.GUIDE','U')       IS NOT NULL DROP TABLE dbo.GUIDE;
IF OBJECT_ID('dbo.GUIDE_LEVEL','U') IS NOT NULL DROP TABLE dbo.GUIDE_LEVEL;
IF OBJECT_ID('dbo.EMPLOYEE','U')    IS NOT NULL DROP TABLE dbo.EMPLOYEE;
IF OBJECT_ID('dbo.GUEST','U')       IS NOT NULL DROP TABLE dbo.GUEST;
IF OBJECT_ID('dbo.CONDO','U')       IS NOT NULL DROP TABLE dbo.CONDO;
IF OBJECT_ID('dbo.ACTIVITY','U')    IS NOT NULL DROP TABLE dbo.ACTIVITY;
GO

CREATE TABLE dbo.EMPLOYEE (
    EmpID      char(4)      NOT NULL,
    LName      varchar(20)  NOT NULL,
    MName      varchar(20)  CONSTRAINT DF_Employee_MName DEFAULT(' '),
    FName      varchar(15)  NOT NULL,
    Gender     char(1)      NOT NULL,
    Phone      char(12)     NOT NULL,
    HireDate   date         NOT NULL,
    MgrNum     char(4)      NULL,
    Department varchar(20)  NOT NULL,
    Salary     decimal(8,2) NULL,
    EType      char(1)      NULL,
    CONSTRAINT PK_Employee PRIMARY KEY (EmpID),
    CONSTRAINT FK_Employee_Manager FOREIGN KEY (MgrNum) REFERENCES dbo.EMPLOYEE(EmpID)
);

CREATE TABLE dbo.ACTIVITY (
    ActID       varchar(3)  NOT NULL PRIMARY KEY,
    [Description] varchar(30) NOT NULL,
    Hours       tinyint     NOT NULL,
    PPP         decimal(4,2) NOT NULL,
    Distance    tinyint     NOT NULL,
    [Type]      varchar(15) NOT NULL
);

CREATE TABLE dbo.CONDO (
    BldgNum   char(1)     NOT NULL,
    UnitNum   char(3)     NOT NULL,
    SqrFt     smallint    NOT NULL,
    Bdrms     tinyint     NOT NULL,
    Baths     tinyint     NOT NULL,
    DailyRate decimal(7,2) NOT NULL,
    CONSTRAINT PK_Condo PRIMARY KEY (BldgNum, UnitNum)
);

CREATE TABLE dbo.HOUSEKEEPER (
    HKID   char(4) NOT NULL,
    [Shift] char(7) NOT NULL CHECK ([Shift] IN ('Shift 1','Shift 2','Shift 3')),
    [Status] char(4) NOT NULL CHECK ([Status] IN ('Perm','Temp')),
    CONSTRAINT PK_Housekeeper PRIMARY KEY (HKID),
    CONSTRAINT FK_Housekeeper_Employee FOREIGN KEY (HKID) REFERENCES dbo.EMPLOYEE(EmpID)
);

CREATE TABLE dbo.GUIDE (
    GuideID       char(4)    NOT NULL PRIMARY KEY,
    [Level]       char(7)    NOT NULL CHECK ([Level] IN ('Level 1','Level 2','Level 3')),
    CertDate      date       NOT NULL,
    CertRenewDate date       NULL,
    CONSTRAINT FK_Guide_Employee FOREIGN KEY (GuideID) REFERENCES dbo.EMPLOYEE(EmpID)
);

CREATE TABLE dbo.GUIDE_LEVEL (
    [Level]       char(7)    NOT NULL CHECK ([Level] IN ('Level 1','Level 2','Level 3')),
    BadgeColor    varchar(20) NOT NULL CHECK (BadgeColor IN ('White','Green','Blue')),
    TrainingHours smallint   NOT NULL CHECK (TrainingHours IN (80,120,160)),
    CONSTRAINT PK_GuideLevel PRIMARY KEY ([Level], BadgeColor)
);

CREATE TABLE dbo.GUEST (
    GuestID      varchar(4)  NOT NULL,
    LName        varchar(20) NOT NULL,
    FName        varchar(15) NOT NULL,
    Street       varchar(50) NOT NULL,
    City         varchar(20) NOT NULL,
    [State]      char(2)     NOT NULL,
    Phone        char(12)    NOT NULL,
    SpouseFName  varchar(15) NOT NULL,
    CONSTRAINT PK_Guest PRIMARY KEY (GuestID)
);

CREATE TABLE dbo.FAMILY (
    GuestID      varchar(4)  NOT NULL,
    FName        varchar(15) NOT NULL,
    Relationship varchar(10) NOT NULL,
    BirthDate    date        NOT NULL,
    CONSTRAINT PK_Family PRIMARY KEY (GuestID, FName),
    CONSTRAINT FK_Family_Guest FOREIGN KEY (GuestID) REFERENCES dbo.GUEST(GuestID)
);

CREATE TABLE dbo.CLEANING (
    ScheduleID int       NOT NULL IDENTITY(1000,1),
    BldgNum    char(1)   NOT NULL,
    UnitNum    char(3)   NOT NULL,
    HKID       char(4)   NOT NULL,
    DateCleaned date     NOT NULL,
    CONSTRAINT PK_Cleaning PRIMARY KEY (ScheduleID),
    CONSTRAINT FK_Cleaning_HK FOREIGN KEY (HKID) REFERENCES dbo.HOUSEKEEPER(HKID),
    CONSTRAINT FK_Cleaning_Condo FOREIGN KEY (BldgNum, UnitNum) REFERENCES dbo.CONDO(BldgNum, UnitNum)
);

CREATE TABLE dbo.BOOKING (
    BookID    int       NOT NULL IDENTITY(100,1),
    BldgNum   char(1)   NOT NULL,
    UnitNum   char(3)   NOT NULL,
    GuestID   varchar(4) NOT NULL,
    StartDate date      NOT NULL,
    EndDate   date      NOT NULL,
    CONSTRAINT PK_Booking PRIMARY KEY (BookID),
    CONSTRAINT FK_Booking_Condo FOREIGN KEY (BldgNum, UnitNum) REFERENCES dbo.CONDO(BldgNum, UnitNum),
    CONSTRAINT FK_Booking_Guest FOREIGN KEY (GuestID) REFERENCES dbo.GUEST(GuestID)
);

CREATE TABLE dbo.RESERVATION (
    ResID         int       NOT NULL IDENTITY(10,1),
    GuestID       varchar(4) NULL,
    EmpID         char(4)    NULL,
    ActID         varchar(3) NOT NULL,
    GuideID       char(4)    NOT NULL,
    RDate         date       NOT NULL,
    NumberInParty tinyint    NOT NULL,
    CONSTRAINT PK_Reservation PRIMARY KEY (ResID),
    CONSTRAINT FK_Reservation_Guest FOREIGN KEY (GuestID) REFERENCES dbo.GUEST(GuestID),
    CONSTRAINT FK_Reservation_Employee FOREIGN KEY (EmpID) REFERENCES dbo.EMPLOYEE(EmpID),
    CONSTRAINT FK_Reservation_Activity FOREIGN KEY (ActID) REFERENCES dbo.ACTIVITY(ActID),
    CONSTRAINT FK_Reservation_Guide FOREIGN KEY (GuideID) REFERENCES dbo.GUIDE(GuideID)
);
