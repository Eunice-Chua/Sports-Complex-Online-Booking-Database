CREATE DATABASE AP_Arena;
GO
USE AP_Arena;

DROP DATABASE AP_Arena;

SELECT USER_NAME() AS CurrentUser;

CREATE TABLE Users (
    UserID NVARCHAR(10) PRIMARY KEY NOT NULL,
    UFullName NVARCHAR(100),
    UEmail NVARCHAR(20) NOT NULL,
    UPhone NVARCHAR(20) NOT NULL,
    UType NVARCHAR(20) NOT NULL,
    UCreatedAt DATETIME,
    UUpdatedAt DATETIME,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)

)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UsersHistory));


CREATE TABLE UserLoginDetails (
    UserID NVARCHAR(10) PRIMARY KEY NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    UserName NVARCHAR(100) NOT NULL,
    LoginName NVARCHAR(100) NOT NULL,
    UPassword NVARCHAR(100) NOT NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo  DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)

)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.UserLoginDetailsHistory));


CREATE TABLE Tournaments(
	TournamentID nvarchar(10) PRIMARY KEY,
	UserID nvarchar(10) FOREIGN KEY REFERENCES Users(UserID), 
	TournamentName nvarchar(50) NOT NULL,
	StartTourTime datetime,
	EndTourTime datetime,
)

CREATE TABLE Facilities (
    FacilityID NVARCHAR(10) PRIMARY KEY NOT NULL,
    FacilityName NVARCHAR(50) NOT NULL,
    Capacity INT,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.FacilitiesHistory));


CREATE TABLE Bookings(
    BookingID nvarchar(10) PRIMARY KEY,
    TournamentID nvarchar(10) FOREIGN KEY REFERENCES Tournaments(TournamentID),
	UserID nvarchar(10) FOREIGN KEY REFERENCES Users(UserID),
    BookType nvarchar(20) NOT NULL,
	BookApprStatus nvarchar(20),
	BCreatedAt datetime,
	BUpdatedAt datetime,
);

CREATE TABLE Transactions (
  TransactionID nvarchar(10) PRIMARY KEY, -- Primary Key
	BookingID nvarchar(10) FOREIGN KEY REFERENCES Bookings(BookingID),
  PaymentCard nvarchar(100), -- Must be 16 digits
  TransStatus nvarchar(20), -- Transaction Status
  TotalAmount DECIMAL(10, 2), -- Total Amount
	PaymentTimestamp DATETIME DEFAULT GETDATE()
);

CREATE TABLE FacilitiesSlot(
	FacilitySlotID nvarchar(10) PRIMARY KEY NOT NULL,
	FacilityID nvarchar(10) FOREIGN KEY REFERENCES Facilities(FacilityID),
	StartSlotTime datetime,
	EndSlotTime datetime,
	Cost nvarchar(50) NOT NULL,
	FaciStatus nvarchar(50) NOT NULL,
	BookingID nvarchar(10) FOREIGN KEY REFERENCES Bookings(BookingID),
)

CREATE TABLE Participants(
	ParticipantsID nvarchar(10) PRIMARY KEY NOT NULL,
	BookingID nvarchar(10) FOREIGN KEY REFERENCES Bookings(BookingID),
	PFullName nvarchar(100),
	PPhone nvarchar(20) NOT NULL,
	PCreatedAt datetime,
	PUpdatedAt datetime,
)

CREATE TABLE Organizers (
    UserID NVARCHAR(10) PRIMARY KEY NOT NULL FOREIGN KEY REFERENCES Users(UserID),
    BusinessName NVARCHAR(100) NOT NULL,
    OrgApprStatus NVARCHAR(10),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    ValidTo  DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.OrganizersHistory));


-----------------------------------------------------------------------------------------------------
-- Insert Values
INSERT INTO Users (UserID, UFullName, UEmail, UPhone, UType, UCreatedAt, UUpdatedAt)
VALUES ('U001', 'EmilyOoi', 'emily@gmail.com', '93826767', 'TournamentOrganizer', GETDATE(), NULL),
('U002', 'JacobTan', 'jacob@gmail.com', '128897666', 'TournamentOrganizer', GETDATE(), NULL),
('U003', 'CelineTan', 'celine@gmail.com', '237868436', 'IndividualCustomer', GETDATE(), NULL),
('U004', 'JoanTan',	'joantan@gmail.com', '2378684222', 'IndividualCustomer', GETDATE(), NULL),
('U005', 'AdamChai', 'adam@gmail.com', '9090990', 'ComplexManager', GETDATE(), NULL),
('U006', 'Ali Hammeed',	'hameed@gmail.com', '7878788787', 'DataAdmin', GETDATE(), NULL),
('U007', 'Yusuf', 'yusuf@gmail.com', '123344488', 'DataAdmin', GETDATE(), NULL)

INSERT INTO UserLoginDetails(UserID, UserName, LoginName, UPassword)
VALUES('U001', 'organizer1', 'organizer1', 'organizer111'),
('U002', 'organizer2', 'organizer2', 'organizer222'),
('U003', 'customer1', 'customer1', 'customer111'),
('U004', 'customer2', 'customer2', 'customer222'),
('U005', 'manager1', 'manager1', 'manager111'),
('U006','admin1', 'admin1', 'admin111'),
('U007', 'admin2', 'admin2', 'admin222');


INSERT INTO Organizers(UserID, BusinessName, OrgApprStatus)
VALUES ('U001', 'Emily Sport Club', NULL),
('U002', 'APU Badminton Club',	'Approved');

INSERT INTO Tournaments(TournamentID, UserID, TournamentName, StartTourTime, EndTourTime)
VALUES ('T001', 'U002', 'APU VBall', '1/1/25 3:00PM', '1/2/25 2:00PM');

INSERT INTO Facilities(FacilityID, FacilityName, Capacity)
VALUES ('V001', 'Volleyball Court 1', '4'),
('V002', 'Volleyball Court 2', '4'),
('V003', 'Volleyball Court 3', '4'),
('V004', 'Volleyball Court 4', '4'),
('B001', 'Badminton Court 1', '4'),
('B002', 'Badminton Court 2', '4'),
('B003', 'Badminton Court 3', '4'),
('B004', 'Badminton Court 4', '4'),
('B005', 'Badminton Court 5', '4'),
('B006', 'Badminton Court 6', '4'),
('B007', 'Badminton Court 7', '4'),
('B008', 'Badminton Court 8', '4'),
('B009', 'Badminton Court 9', '4'),
('B010', 'Badminton Court 10', '4'),
('S001', 'Squash Court 1', '4'),
('S002', 'Squash Court 2', '4'),
('S003', 'Squash Court 3', '4'),
('S004', 'Squash Court 4', '4'),
('S005', 'Squash Court 5', '4'),
('P001', 'Swimming Pool 1', '10'),
('P002', 'Swimming Pool 2', '10'),
('P003', 'Swimming Pool 3', '10'),
('BK001', 'BasketBall 1', '4'),
('BK002', 'BasketBall 2', '4'),
('BK003', 'BasketBall 3', '4'),
('BK004', 'BasketBall 4', '4'),
('BK005', 'BasketBall 5', '4');

INSERT INTO Bookings(BookingID, TournamentID, UserID, BookType, BookApprStatus, BCreatedAt)
VALUES 
('B001', 'T001', 'U002', 'Tournament', 'Approved', GETDATE()),
('B002', NULL, 'U003', 'Individual', 'Booked', GETDATE());

INSERT INTO FacilitiesSlot(FacilitySlotID, FacilityID, StartSlotTime, EndSlotTime, Cost, FaciStatus, BookingID)
VALUES ('FS001','V001', '1/1/25 1:00PM', '1/1/25 2:00PM', '23.9', 'Available', NULL),
('FS002', 'V001', '1/1/25 2:00PM', '1/1/25 3:00PM', '23.9', 'Available', NULL),
('FS003', 'V001', '1/1/25 3:00PM', '1/1/25 4:00PM', '23.9', 'Unavailable', 'B001'),
('FS004', 'V001', '1/1/25 4:00PM', '1/1/25 5:00PM', '23.9', 'Unavailable', 'B001'),
('FS005', 'V001', '1/2/25 1:00PM', '1/2/25 2:00PM', '23.9', 'Unavailable', 'B001'),
('FS006', 'V001', '1/2/25 2:00PM', '1/2/25 3:00PM', '23.9', 'Available', NULL),
('FS007', 'V001', '1/2/25 3:00PM', '1/2/25 4:00PM', '23.9', 'Available', NULL),
('FS008', 'V001', '1/2/25 4:00PM', '1/2/25 5:00PM', '23.9', 'Unavailable', 'B002'),
('FS009', 'V002', '1/2/25 1:00PM', '1/2/25 2:00PM', '23.9', 'Available', NULL),
('FS010', 'V002', '1/2/25 2:00PM', '1/2/25 3:00PM', '23.9', 'Available', NULL),
('FS011', 'V002', '1/2/25 3:00PM', '1/2/25 4:00PM', '23.9', 'Available', NULL);

INSERT INTO Participants (ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt, PUpdatedAt)
VALUES ('P001', 'B001', 'John Tan', '123456789', GETDATE(), NULL),
('P002', 'B001', 'Alex Chua', '124455889', GETDATE(), NULL),
('P003', 'B001', 'Mindy Lim', '124455667', GETDATE(), NULL),
('P004', 'B001', 'Sophia Cheng', '126677229', GETDATE(), NULL),
('P005', 'B001', 'Daniel Tan', '129988226', GETDATE(), NULL),
('P006', 'B001', 'Kevin Lee', '123388226', GETDATE(), NULL),
('P007', 'B002', 'Joey Chew', '146901459', GETDATE(), NULL);

INSERT INTO Transactions (TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount)
VALUES
    ('TR001', 'B001', '1987102810281721', 'Completed', '71.70'),
	('TR002', 'B002', NULL, 'Pending', '23.90');

------------------------------------------------------------------------------------
USE AP_Arena

SELECT * FROM Users;
SELECT * FROM UsersHistory;

SELECT * FROM UserLoginDetails;
SELECT * FROM UserLoginDetailsHistory;

SELECT * FROM Tournaments;
SELECT * FROM TournamentsAudit;

SELECT * FROM Facilities;
SELECT * FROM FacilitiesHistory;

SELECT * FROM FacilitiesSlot;
SELECT * FROM FacilitiesSlotAudit;

SELECT * FROM Participants;
SELECT * FROM ParticipantsAudit;

SELECT * FROM Bookings;
SELECT * FROM BookingsAudit;

SELECT * FROM Organizers;
SELECT * FROM OrganizersHistory;

SELECT * FROM Transactions;
SELECT * FROM TransactionsAudit;

-----------------------------------------------------------------------------------

USE AP_Arena
DROP TABLE Organizers
DROP TABLE Participants
DROP TABLE FacilitiesSlot
DROP TABLE Facilities
DROP TABLE UserLoginDetails
Drop TABLE Transactions
DROP TABLE Bookings
DROP TABLE Tournaments
DROP TABLE Users

------------------------------------------------------------------------------------
USE AP_Arena;

CREATE ROLE DataAdmin;
CREATE ROLE ComplexManager;
CREATE ROLE TournamentOrganizer;
CREATE ROLE IndividualCustomer;
CREATE ROLE Auditor;

-- Admin
CREATE LOGIN admin1 WITH PASSWORD = 'admin111';
CREATE USER admin1 FOR LOGIN admin1;
ALTER ROLE DataAdmin ADD MEMBER admin1;

CREATE LOGIN admin2 WITH PASSWORD = 'admin222';
CREATE USER admin2 FOR LOGIN admin2;
ALTER ROLE DataAdmin ADD MEMBER admin2;

-- Complex Manager
CREATE LOGIN manager1 WITH PASSWORD = 'manager111';
CREATE USER manager1 FOR LOGIN manager1;
ALTER ROLE ComplexManager ADD MEMBER manager1;

-- Tournament Organizer
CREATE LOGIN organizer1 WITH PASSWORD = 'organizer111';
CREATE USER organizer1 FOR LOGIN organizer1;
ALTER ROLE TournamentOrganizer ADD MEMBER organizer1;

CREATE LOGIN organizer2 WITH PASSWORD = 'organizer222';
CREATE USER organizer2 FOR LOGIN organizer2;
ALTER ROLE TournamentOrganizer ADD MEMBER organizer2;

-- Individual Customer
CREATE LOGIN customer1 WITH PASSWORD = 'customer111';
CREATE USER customer1 FOR LOGIN customer1;
ALTER ROLE IndividualCustomer ADD MEMBER customer1;

CREATE LOGIN customer2 WITH PASSWORD = 'customer222';
CREATE USER customer2 FOR LOGIN customer2;
ALTER ROLE IndividualCustomer ADD MEMBER customer2;

-- Auditor
CREATE LOGIN auditor1 WITH PASSWORD = 'auditor111';
CREATE USER auditor1 FOR LOGIN auditor1;
ALTER ROLE Auditor ADD MEMBER auditor1;

USE master;
-- Create Server Role for Auditor
CREATE SERVER ROLE AuditorServerRole;
ALTER SERVER ROLE AuditorServerRole ADD MEMBER auditor1;
GRANT VIEW SERVER STATE TO Auditor;
GRANT CONTROL SERVER TO Auditor;

USE AP_Arena;
GRANT CONTROL ON SCHEMA::dbo TO Auditor; 
GRANT EXECUTE ON SCHEMA::dbo TO Auditor;

-- Create Server Role for Admin
CREATE SERVER ROLE LoginCreatorAdmin;
GRANT ALTER ANY LOGIN TO LoginCreatorAdmin; 
ALTER SERVER ROLE LoginCreatorAdmin ADD MEMBER admin1;
ALTER SERVER ROLE LoginCreatorAdmin ADD MEMBER admin2;

USE AP_Arena;

-- Grant permission to create users in the database
GRANT ALTER ANY USER TO DataAdmin;
GRANT ALTER ANY ROLE TO DataAdmin;

GRANT CONTROL ON SCHEMA::dbo TO DataAdmin; 
GRANT EXECUTE ON SCHEMA::dbo TO DataAdmin;

GRANT SELECT ON BookingsAudit TO Auditor;
GRANT SELECT ON FacilitiesSlotAudit TO Auditor;
GRANT SELECT ON ParticipantsAudit TO Auditor;
GRANT SELECT ON TournamentsAudit TO Auditor;
GRANT SELECT ON UsersHistory TO Auditor;
GRANT SELECT ON UserLoginDetailsHistory TO Auditor;
GRANT SELECT ON TournamentsAudit TO Auditor;
GRANT SELECT ON FacilitiesHistory TO Auditor;
GRANT SELECT ON OrganizersHistory TO Auditor;

CREATE USER SystemUser WITHOUT LOGIN;
GRANT EXECUTE ON SP_InsertUsers TO SystemUser;

SELECT 
    dp.name AS DatabaseRoleName,
    perm.permission_name,
    perm.state_desc,
    obj.name AS ObjectName,
    obj.type_desc AS ObjectType
FROM sys.database_permissions AS perm
JOIN sys.database_principals AS dp
    ON perm.grantee_principal_id = dp.principal_id
LEFT JOIN sys.objects AS obj
    ON perm.major_id = obj.object_id
WHERE dp.name = 'Auditor'
ORDER BY obj.name, perm.permission_name;

Update Users
SET UFullName = 'Emily'
WHERE UserID = 'U001'