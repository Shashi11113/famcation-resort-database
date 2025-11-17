USE FamCation;
GO

-- Minimal demo seed. The full instructor seed is stored under /original/documents as docx.
SET NOCOUNT ON;

INSERT INTO dbo.EMPLOYEE (EmpID, LName, MName, FName, Gender, Phone, HireDate, MgrNum, Department, Salary, EType) VALUES
('NE01','Neilson',DEFAULT,'Evan','M','480-555-8945','2010-06-03',NULL,'GM',185000,NULL),
('MJ01','Marzeen',DEFAULT,'Jonny','M','602-500-8945','2015-06-03','NE01','Marketing',150000,NULL),
('CG01','Connor',DEFAULT,'Geoffrey','M','480-345-8997','2011-06-03','NE01','HR',150000,NULL);

INSERT INTO dbo.CONDO (BldgNum, UnitNum, SqrFt, Bdrms, Baths, DailyRate) VALUES
('A','101',1030,2,1,130.00),
('A','102',1164,2,2,145.00),
('A','105',1575,3,2,160.00);

INSERT INTO dbo.GUEST (GuestID, LName, FName, Street, City, State, Phone, SpouseFName) VALUES
('G1','Northwood','Liam','2011 Lemon','Springfield','MA','413-555-3212','Stephanie'),
('G5','McLean','Adam','2222 Orange','Rome','ME','207-555-5663','Judy');

INSERT INTO dbo.ACTIVITY (ActID, [Description], Hours, PPP, Distance, [Type]) VALUES
('H1','Eagle Falls',4,15.00,5,'Hike'),
('B3','White River National Park',4,20.00,12,'Bike'),
('HB2','Black Mountain Ranch',4,30.00,12,'Horseback');

INSERT INTO dbo.BOOKING (BldgNum, UnitNum, GuestID, StartDate, EndDate) VALUES
('A','101','G1','2022-05-20','2022-05-27'),
('A','105','G5','2022-07-01','2022-07-08');

INSERT INTO dbo.HOUSEKEEPER (HKID, [Shift], [Status]) VALUES
('TM01','Shift 1','Perm'),
('AJ01','Shift 1','Perm');

INSERT INTO dbo.GUIDE (GuideID, [Level], CertDate, CertRenewDate) VALUES
('AM01','Level 2','2018-08-12','2020-08-13'),
('KS02','Level 1','2019-08-05','2021-08-05');

INSERT INTO dbo.GUIDE_LEVEL ([Level], BadgeColor, TrainingHours) VALUES
('Level 1','White',80),
('Level 2','Green',120),
('Level 3','Blue',160);

INSERT INTO dbo.RESERVATION (GuestID, EmpID, ActID, GuideID, RDate, NumberInParty) VALUES
('G1',NULL,'H1','AM01','2022-05-23',4),
('G5',NULL,'HB2','KS02','2022-08-10',5);
