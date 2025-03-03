-- Logging Tables for Bookings, Facilities Slot, Participants, Tournaments, Transactions

USE AP_Arena

--- Trigger DML Audit (Tournaments)---------------------------------------------------------
CREATE TABLE TournamentsAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,     -- Unique ID for the audit entry
    Action NVARCHAR(10),                      -- Type of action: INSERT, UPDATE, DELETE
    TournamentID NVARCHAR(10),                -- ID of the tournament
    UserID NVARCHAR(10),                      -- User ID associated with the tournament
    TournamentName NVARCHAR(50),              -- Name of the tournament
    StartTourTime DATETIME,                   -- Start time of the tournament
    EndTourTime DATETIME,                     -- End time of the tournament
    AuditTimestamp DATETIME DEFAULT GETDATE() -- When the audit was logged
);
GO

CREATE TRIGGER trg_TournamentsAudit
ON Tournaments
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Log INSERT actions
    BEGIN
        INSERT INTO TournamentsAudit (Action, TournamentID, UserID, TournamentName, StartTourTime, EndTourTime)
        SELECT 
            'INSERT',                       -- Action type
            TournamentID,                   -- Tournament ID
            UserID,                         -- User ID
            TournamentName,                 -- Tournament name
            StartTourTime,                  -- Start time
            EndTourTime                     -- End time
        FROM inserted;
    END

    -- Log DELETE actions
    BEGIN
        INSERT INTO TournamentsAudit (Action, TournamentID, UserID, TournamentName, StartTourTime, EndTourTime)
        SELECT 
            'DELETE',                       -- Action type
            TournamentID,                   -- Tournament ID
            UserID,                         -- User ID
            TournamentName,                 -- Tournament name
            StartTourTime,                  -- Start time
            EndTourTime                     -- End time
        FROM deleted;
    END
END;
GO

--- Trigger DML Audit (Bookings)---------------------------------------------------------

CREATE TABLE BookingsAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,     -- Unique ID for the audit entry
    Action NVARCHAR(10),                      -- Type of action: INSERT, UPDATE, DELETE
    BookingID NVARCHAR(10),                   -- ID of the booking
    TournamentID NVARCHAR(10),                -- Tournament ID associated with the booking
    UserID NVARCHAR(10),                      -- User ID associated with the booking
    BookType NVARCHAR(20),                    -- Booking type
    BookApprStatus NVARCHAR(20),              -- Booking approval status
    BCreatedAt DATETIME,                      -- Booking creation time
    BUpdatedAt DATETIME,                      -- Booking update time
    AuditTimestamp DATETIME DEFAULT GETDATE() -- When the audit was logged
);
GO
CREATE TRIGGER trg_BookingsAudit
ON Bookings
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Log INSERT actions
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO BookingsAudit (Action, BookingID, TournamentID, UserID, BookType, BookApprStatus, BCreatedAt, BUpdatedAt)
        SELECT 
            'INSERT', BookingID, TournamentID, UserID, BookType, BookApprStatus, BCreatedAt, BUpdatedAt
        FROM inserted;
    END

    -- Log DELETE actions
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO BookingsAudit (Action, BookingID, TournamentID, UserID, BookType, BookApprStatus, BCreatedAt, BUpdatedAt)
        SELECT 
            'DELETE', BookingID, TournamentID, UserID, BookType, BookApprStatus, BCreatedAt, BUpdatedAt
        FROM deleted;
    END

END;
GO


--- Trigger DML Audit (FacilitiesSlot)---------------------------------------------------------

CREATE TABLE FacilitiesSlotAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,         -- Unique ID for the audit entry
    Action NVARCHAR(10),                          -- Type of action: INSERT, UPDATE, DELETE
    FacilitySlotID NVARCHAR(10),                  -- Facility slot ID
    FacilityID NVARCHAR(10),                      -- Facility ID
    StartSlotTime DATETIME,                       -- Slot start time
    EndSlotTime DATETIME,                         -- Slot end time
    Cost NVARCHAR(50),                            -- Slot cost
    FaciStatus NVARCHAR(50),                      -- Facility status
    BookingID NVARCHAR(10),                       -- Associated booking ID
    AuditTimestamp DATETIME DEFAULT GETDATE()     -- Timestamp of the audit entry
);
GO
CREATE TRIGGER trg_FacilitiesSlotAudit
ON FacilitiesSlot
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Log INSERT actions
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO FacilitiesSlotAudit (Action, FacilitySlotID, FacilityID, StartSlotTime, EndSlotTime, Cost, FaciStatus, BookingID)
        SELECT 
            'INSERT', FacilitySlotID, FacilityID, StartSlotTime, EndSlotTime, Cost, FaciStatus, BookingID
        FROM inserted;
    END

    -- Log DELETE actions
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO FacilitiesSlotAudit (Action, FacilitySlotID, FacilityID, StartSlotTime, EndSlotTime, Cost, FaciStatus, BookingID)
        SELECT 
            'DELETE', FacilitySlotID, FacilityID, StartSlotTime, EndSlotTime, Cost, FaciStatus, BookingID
        FROM deleted;
    END
END;
GO
--- Trigger DML Audit (Participants)---------------------------------------------------------
CREATE TABLE ParticipantsAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,     -- Unique ID for the audit entry
    Action NVARCHAR(10),                      -- Type of action: INSERT, UPDATE, DELETE
    ParticipantsID NVARCHAR(10),              -- Participant ID
    BookingID NVARCHAR(10),                   -- Booking ID associated with the participant
    PFullName NVARCHAR(100),                  -- Participant full name
    PPhone NVARCHAR(20),                      -- Participant phone number
    PCreatedAt DATETIME,                      -- Participant creation time
    PUpdatedAt DATETIME,                      -- Participant update time
    AuditTimestamp DATETIME DEFAULT GETDATE() -- When the audit was logged
);
GO
CREATE TRIGGER trg_ParticipantsAudit
ON Participants
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Log INSERT actions
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO ParticipantsAudit (Action, ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt, PUpdatedAt)
        SELECT 
            'INSERT', ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt, PUpdatedAt
        FROM inserted;
    END

    -- Log DELETE actions
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO ParticipantsAudit (Action, ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt, PUpdatedAt)
        SELECT 
            'DELETE', ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt, PUpdatedAt
        FROM deleted;
    END


END;
GO
--- Trigger DML Audit (Transactions)---------------------------------------------------------
-- Create the TransactionsAudit table
CREATE TABLE TransactionsAudit (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,     -- Unique ID for the audit entry
    Action NVARCHAR(10),                      -- Type of action: INSERT, UPDATE, DELETE
    TransactionID NVARCHAR(10),               -- Transaction ID
    BookingID NVARCHAR(10),                   -- Booking ID associated with the transaction
    PaymentCard NVARCHAR(100),                -- Payment card details
    TransStatus NVARCHAR(20),                 -- Transaction status
    TotalAmount DECIMAL(10, 2),               -- Total amount of the transaction
    PaymentTimestamp DATETIME,                -- Payment timestamp
    AuditTimestamp DATETIME DEFAULT GETDATE() -- When the audit was logged
);
GO

-- Create the trigger for auditing Transactions table changes
CREATE TRIGGER trg_TransactionsAudit
ON Transactions
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Log INSERT actions
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        INSERT INTO TransactionsAudit (Action, TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp)
        SELECT 
            'INSERT', TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp
        FROM inserted;
    END

    -- Log UPDATE actions
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO TransactionsAudit (Action, TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp)
        SELECT 
            'UPDATE', TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp
        FROM inserted;
    END

    -- Log DELETE actions
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        INSERT INTO TransactionsAudit (Action, TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp)
        SELECT 
            'DELETE', TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp
        FROM deleted;
    END
END;
GO


--- Trigger 24Hours Checking (Participants Booking Update)---------------------------------------------------------

CREATE TRIGGER trg_ValidateParticipantUpdate
ON Participants
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    -- Declare variables
    DECLARE @CurrentTime DATETIME = GETDATE();
    DECLARE @BookingID NVARCHAR(10);
    DECLARE @EarliestSlotTime DATETIME;

    -- Handle INSERT operation
    IF NOT EXISTS (SELECT * FROM deleted) AND EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Get the associated BookingID and earliest StartSlotTime
        SELECT TOP 1 
            @BookingID = i.BookingID
        FROM inserted i;

        SELECT @EarliestSlotTime = MIN(fs.StartSlotTime)
        FROM FacilitiesSlot fs
        WHERE fs.BookingID = @BookingID;

        -- Validate if the current time is at least 24 hours before the earliest StartSlotTime
        IF @EarliestSlotTime IS NOT NULL AND DATEDIFF(HOUR, @CurrentTime, @EarliestSlotTime) < 24
        BEGIN
            RAISERROR ('Cannot insert: Insert time must be at least 24 hours before the earliest slot start time.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Perform the insert if validation passes
        INSERT INTO Participants (ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt, PUpdatedAt)
        SELECT ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt, NULL
        FROM inserted;
    END

    -- Handle UPDATE operation
    IF EXISTS (SELECT * FROM deleted) AND EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Get the associated BookingID and earliest StartSlotTime
        SELECT TOP 1 
            @BookingID = i.BookingID
        FROM inserted i;

        SELECT @EarliestSlotTime = MIN(fs.StartSlotTime)
        FROM FacilitiesSlot fs
        WHERE fs.BookingID = @BookingID;

        -- Validate if the current time is at least 24 hours before the earliest StartSlotTime
        IF @EarliestSlotTime IS NOT NULL AND DATEDIFF(HOUR, @CurrentTime, @EarliestSlotTime) < 24
        BEGIN
            RAISERROR ('Cannot update: Update time must be at least 24 hours before the earliest slot start time.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Perform the update if validation passes
        UPDATE Participants
        SET ParticipantsID = i.ParticipantsID,
            BookingID = i.BookingID,
            PFullName = i.PFullName,
            PPhone = i.PPhone,
            PCreatedAt = i.PCreatedAt,
            PUpdatedAt = @CurrentTime
        FROM inserted i
        WHERE Participants.ParticipantsID = i.ParticipantsID;
    END
	-- Handle DELETE operation
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted)
    BEGIN
        -- Get the associated BookingID and earliest StartSlotTime
        SELECT TOP 1 
            @BookingID = d.BookingID
        FROM deleted d;

        SELECT @EarliestSlotTime = MIN(fs.StartSlotTime)
        FROM FacilitiesSlot fs
        WHERE fs.BookingID = @BookingID;

        -- Validate if the current time is at least 24 hours before the earliest StartSlotTime
        IF @EarliestSlotTime IS NOT NULL AND DATEDIFF(HOUR, @CurrentTime, @EarliestSlotTime) < 24
        BEGIN
            RAISERROR ('Cannot delete: Delete time must be at least 24 hours before the earliest slot start time.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Perform the delete if validation passes
        DELETE FROM Participants
        WHERE ParticipantsID IN (SELECT ParticipantsID FROM deleted);
    END
END;



