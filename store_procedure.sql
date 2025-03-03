-- Store Procedures
USE AP_Arena
SELECT USER_NAME() AS CurrentUser;

------------------------------------------------------------------------------------
-- Insert User
CREATE PROCEDURE SP_InsertUsers
    @UFullName NVARCHAR(100),
    @UEmail NVARCHAR(100),
    @UPhone NVARCHAR(20),
    @UType NVARCHAR(20)
AS
BEGIN
    DECLARE @UserID NVARCHAR(10);

	-- Check for duplicate UserName and LoginName
    IF EXISTS (SELECT 1 FROM Users WHERE UEmail = @UEmail OR UPhone = @UPhone)
    BEGIN
        RAISERROR('The same email or phone number already exists.', 16, 1) WITH NOWAIT;
        RETURN;
    END;

    -- Generate the new UserID
    SELECT @UserID = 'U' + RIGHT('000' + CAST(ISNULL(MAX(CAST(SUBSTRING(UserID, 2, LEN(UserID)) AS INT)), 0) + 1 AS NVARCHAR), 3)
    FROM Users;

    -- Insert the new user into the Users table
    INSERT INTO Users (UserID, UFullName, UEmail, UPhone, UType, UCreatedAt)
    VALUES (@UserID, @UFullName, @UEmail, @UPhone, @UType, GETDATE());
END;

------------------------------------------------------------------------------------
-- Create Login
CREATE PROCEDURE SP_CreateLogin
    @UserID NVARCHAR(10),
    @UserName NVARCHAR(100),
    @LoginName NVARCHAR(100),
    @UPassword NVARCHAR(100),
    @RoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Input validation
    IF @UserID IS NULL OR @UserID = ''
    BEGIN
        RAISERROR('UserID cannot be NULL or empty.', 16, 1) WITH NOWAIT;
        RETURN;
    END;

    IF @UserName IS NULL OR @UserName = ''
    BEGIN
        RAISERROR('UserName cannot be NULL or empty.', 16, 1) WITH NOWAIT;
        RETURN;
    END;

    IF @LoginName IS NULL OR @LoginName = ''
    BEGIN
        RAISERROR('LoginName cannot be NULL or empty.', 16, 1) WITH NOWAIT;
        RETURN;
    END;
	    -- Check for duplicate UserName and LoginName
    IF EXISTS (SELECT 1 FROM UserLoginDetails WHERE UserName = @UserName OR LoginName = @LoginName)
    BEGIN
        RAISERROR('UserName or LoginName already exists.', 16, 1) WITH NOWAIT;
        RETURN;
    END;

    IF @UPassword IS NULL OR @UPassword = ''
    BEGIN
        RAISERROR('Password cannot be NULL or empty.', 16, 1) WITH NOWAIT;
        RETURN;
    END;

    IF @RoleName IS NULL OR @RoleName = ''
    BEGIN
        RAISERROR('RoleName cannot be NULL or empty.', 16, 1) WITH NOWAIT;
        RETURN;
    END;

    -- Check if the UserID exists in the Users table
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
    BEGIN
        RAISERROR('Invalid UserID. User does not exist in the Users table.', 16, 1) WITH NOWAIT;
        RETURN;
    END;

    -- Generate password hash
    DECLARE @PasswordHash VARBINARY(64);
    SET @PasswordHash = HASHBYTES('SHA2_512', CONCAT(@UPassword, CAST(NEWID() AS VARCHAR(36))));

    -- Insert into UserLoginDetails table
    INSERT INTO UserLoginDetails (UserID, UserName, LoginName, PasswordHash)
    VALUES (@UserID, @UserName, @LoginName, @PasswordHash);

    -- Create dynamic SQL for login, user, and role mapping
    DECLARE @CreateLoginQuery NVARCHAR(MAX);
    DECLARE @CreateUserQuery NVARCHAR(MAX);
    DECLARE @AlterRoleQuery NVARCHAR(MAX);

    -- Create SQL Server login
    SET @CreateLoginQuery = 
        'CREATE LOGIN ' + QUOTENAME(@LoginName) + ' WITH PASSWORD = ''' + @UPassword + ''';'; 
    EXEC(@CreateLoginQuery); 

    -- Map login to database user
    SET @CreateUserQuery = 
        'CREATE USER ' + QUOTENAME(@UserName) + ' FOR LOGIN ' + QUOTENAME(@LoginName) + ';';
    EXEC(@CreateUserQuery);

    -- Add the user to the specified role
    SET @AlterRoleQuery = 
        'ALTER ROLE ' + QUOTENAME(@RoleName) + ' ADD MEMBER ' + QUOTENAME(@UserName) + ';';
    EXEC(@AlterRoleQuery);

    PRINT 'Login and user created successfully.';
END;

------------------------------------------------------------------------------------
-- Update User
CREATE PROCEDURE SP_UpdateUser
	@UserID nvarchar(10),
	@UFullName nvarchar(100) = NULL,
    @UEmail nvarchar(20) = NULL,
	@UPhone nvarchar(20) = NULL,
	@UType nvarchar(10) = NULL
AS
BEGIN
    -- Check if UserID exists in the table
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
    BEGIN
        RAISERROR ('UserID does not exist.', 16, 1);
        RETURN;
    END;

	UPDATE Users
    SET
        UFullName = COALESCE(@UFullName, UFullName), -- Update only if a new value is provided, if not it will remain unchanged.
        UEmail = COALESCE(@UEmail, UEmail),
        UPhone = COALESCE(@UPhone, UPhone),
        UType = COALESCE(@UType, UType),
        UUpdatedAt = GETDATE() -- Update the timestamp
    WHERE UserID = @UserID;
END;

------------------------------------------------------------------------------------
-- Update Current User
CREATE PROCEDURE SP_UpdateCurrentUser
	@UserID nvarchar(10),
	@UFullName nvarchar(100) = NULL,
    @UEmail nvarchar(20) = NULL,
	@UPhone nvarchar(20) = NULL,
	@UType nvarchar(10) = NULL
AS
BEGIN
    -- Check if UserID exists in the table
    IF NOT EXISTS (
	    SELECT 1 FROM Users WHERE UserID = @UserID AND
			@UserID = (SELECT UL.UserID FROM UserLoginDetails UL WHERE UL.LoginName = USER_NAME()))
    BEGIN
        RAISERROR ('UserID does not exist or no permission.', 16, 1);
        RETURN;
    END;

	UPDATE Users
    SET
        UFullName = COALESCE(@UFullName, UFullName), -- Update only if a new value is provided, if not it will remain unchanged.
        UEmail = COALESCE(@UEmail, UEmail),
        UPhone = COALESCE(@UPhone, UPhone),
        UType = COALESCE(@UType, UType),
        UUpdatedAt = GETDATE() -- Update the timestamp
    WHERE UserID = @UserID;
END;


------------------------------------------------------------------------------------
-- Delete User
CREATE PROCEDURE SP_DeleteUser
	@UserID nvarchar(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
    BEGIN
        RAISERROR ('UserID does not exist.', 16, 1);
        RETURN;
    END;

    DELETE FROM UserLoginDetails
    WHERE UserID = @UserID;

	DELETE FROM Users
	WHERE UserID = @UserID;
END;

------------------------------------------------------------------------------------
-- Approve Organizer
CREATE PROCEDURE SP_ApproveOrganizer
	@UserID nvarchar(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UType = 'TournamentOrganizer')
    BEGIN
        RAISERROR ('UserID does not exist / UType is not Organizer.', 16, 1);
        RETURN;
    END;

	UPDATE Organizers
	SET OrgApprStatus = 'Approved'
	WHERE UserID = @UserID;
END;


------------------------------------------------------------------------------------
-- Reject Organizer
CREATE PROCEDURE SP_RejectOrganizer
	@UserID nvarchar(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UType = 'TournamentOrganizer')
    BEGIN
        RAISERROR ('UserID does not exist / UType is not Organizer.', 16, 1);
        RETURN;
    END;

	UPDATE Organizers
	SET OrgApprStatus = 'Rejected'
	WHERE UserID = @UserID;
END;

------------------------------------------------------------------------------------
-- create facility
CREATE PROCEDURE SP_CreateFacility
	@FacilityName nvarchar(50),
	@Capacity int
AS
BEGIN
    DECLARE @FacilityPrefix nvarchar(10);
    DECLARE @FacilityID nvarchar(10);

    -- Check for duplicate FacilityName
    IF EXISTS (SELECT 1 FROM Facilities WHERE FacilityName = @FacilityName)
    BEGIN
        RAISERROR ('FacilityName already exists.', 16, 1);
        RETURN;
    END;

    -- Determine the prefix based on the FacilityName
    IF CHARINDEX('Volleyball Court', @FacilityName) > 0
        SET @FacilityPrefix = 'V';
    ELSE IF CHARINDEX('Badminton Court', @FacilityName) > 0
        SET @FacilityPrefix = 'B';
    ELSE IF CHARINDEX('Squash Court', @FacilityName) > 0
        SET @FacilityPrefix = 'S';
    ELSE IF CHARINDEX('Swimming Pool', @FacilityName) > 0
        SET @FacilityPrefix = 'P';
    ELSE IF CHARINDEX('BasketBall', @FacilityName) > 0
        SET @FacilityPrefix = 'BK';

    -- Generate the next FacilityID based on the prefix
    SELECT @FacilityID = @FacilityPrefix + 
        RIGHT('000' + CAST(
            ISNULL(MAX(CAST(SUBSTRING(FacilityID, LEN(@FacilityPrefix) + 1, LEN(FacilityID)) AS INT)), 0) + 1 
            AS NVARCHAR), 3)
    FROM Facilities
    WHERE FacilityID LIKE @FacilityPrefix + '%';

	INSERT INTO Facilities(FacilityID, FacilityName, Capacity)
    VALUES (@FacilityID, @FacilityName, @Capacity);
END;

------------------------------------------------------------------------------------
-- create facilities slot
-- Create Slot
CREATE PROCEDURE SP_CreateFacilitiesSlot
    @FacilityID nvarchar(10),
    @StartSlotTime datetime,
    @EndSlotTime datetime,
    @Cost nvarchar(50),
    @FaciStatus nvarchar(50) = 'Available',
    @BookingID nvarchar(10) = NULL  -- Use actual NULL value
AS
BEGIN
    DECLARE @FacilitySlotID nvarchar(10);

    -- Check if the facility exists
    IF NOT EXISTS (SELECT 1 FROM Facilities WHERE FacilityID = @FacilityID)
    BEGIN
        RAISERROR ('Facility does not exist.', 16, 1);
        RETURN;
    END;

    -- Check for overlapping time slots
    IF EXISTS (
        SELECT 1 
        FROM FacilitiesSlot
        WHERE FacilityID = @FacilityID
          AND (
                (@StartSlotTime > StartSlotTime AND @StartSlotTime < EndSlotTime) OR
                (@EndSlotTime > StartSlotTime AND @EndSlotTime < EndSlotTime)
              )
    )
    BEGIN
        RAISERROR ('Time slot overlaps with an existing slot.', 16, 1);
        RETURN;
    END;

    -- Check for duplicate entries (FacilityID, StartSlotTime, EndSlotTime)
    IF EXISTS (
        SELECT 1
        FROM FacilitiesSlot
        WHERE FacilityID = @FacilityID
          AND StartSlotTime = @StartSlotTime
          AND EndSlotTime = @EndSlotTime
    )
    BEGIN
        RAISERROR ('Duplicate slot found for the same facility.', 16, 1);
        RETURN;
    END;

    -- Auto-generate FacilitySlotID (FS001, FS002...)
    SELECT @FacilitySlotID = 'FS' + RIGHT('000' + CAST(ISNULL(MAX(CAST(SUBSTRING(FacilitySlotID, 3, LEN(FacilitySlotID)) AS INT)), 0) + 1 AS nvarchar), 3)
    FROM FacilitiesSlot;

    -- Insert into FacilitiesSlot, handling NULL for @BookingID
    INSERT INTO FacilitiesSlot (FacilitySlotID, FacilityID, StartSlotTime, EndSlotTime, Cost, FaciStatus, BookingID)
    VALUES (
        @FacilitySlotID, 
        @FacilityID, 
        @StartSlotTime, 
        @EndSlotTime, 
        @Cost, 
        @FaciStatus, 
        @BookingID -- Can be NULL if not provided
    );
END;

------------------------------------------------------------------------------------
-- Create Tournament + auto create Booking
CREATE PROCEDURE SP_CreateTournament
    @UserID NVARCHAR(10),
    @TournamentName NVARCHAR(50),
    @StartTourTime DATETIME,
    @EndTourTime DATETIME
AS
BEGIN
    DECLARE @TournamentID NVARCHAR(10);
    DECLARE @BookingID NVARCHAR(10);

    -- Validate that the UserID exists and is a Tournament Organizer
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UType = 'TournamentOrganizer')
    BEGIN
        RAISERROR ('Only organizers are allowed to create tournaments.', 16, 1);
        RETURN;
    END;

    -- Check for duplicate TournamentName
    IF EXISTS (SELECT 1 FROM Tournaments WHERE TournamentName = @TournamentName)
    BEGIN
        RAISERROR ('A tournament with this name already exists. Please choose a different name.', 16, 1);
        RETURN;
    END;

    -- Generate unique TournamentID
    SELECT @TournamentID = 'T' + RIGHT('0' + CAST(ISNULL(MAX(CAST(SUBSTRING(TournamentID, 2, LEN(TournamentID)) AS INT)), 0) + 1 AS NVARCHAR), 3)
    FROM Tournaments;

    -- Insert the new tournament
    INSERT INTO Tournaments (TournamentID, UserID, TournamentName, StartTourTime, EndTourTime)
    VALUES (@TournamentID, @UserID, @TournamentName, @StartTourTime, @EndTourTime);

    -- Generate unique BookingID
    SELECT @BookingID = 'B' + RIGHT('000' + CAST(ISNULL(MAX(CAST(SUBSTRING(BookingID, 2, LEN(BookingID)) AS INT)), 0) + 1 AS NVARCHAR), 3)
    FROM Bookings;

    -- Insert the new booking
    INSERT INTO Bookings (BookingID, TournamentID, UserID, BookType, BookApprStatus, BCreatedAt, BUpdatedAt)
    VALUES (@BookingID, @TournamentID, @UserID, 'Tournament', 'Pending', GETDATE(), NULL);

    PRINT 'Tournament created successfully.';
END;

------------------------------------------------------------------------------------
-- Make Booking - for individual customer
-- auto create Booking
CREATE PROCEDURE SP_CreateBooking
    @UserID NVARCHAR(10)
AS
BEGIN
    DECLARE @BookingID NVARCHAR(10);

	-- Validate that the UserID exists and is a Individual Customer
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UType = 'IndividualCustomer')
    BEGIN
        RAISERROR ('Only indivudual customer are allowed to create this booking.', 16, 1);
        RETURN;
    END;

    -- Generate unique BookingID
    SELECT @BookingID = 'B' + RIGHT('000' + CAST(ISNULL(MAX(CAST(SUBSTRING(BookingID, 2, LEN(BookingID)) AS INT)), 0) + 1 AS NVARCHAR), 3)
    FROM Bookings;

    -- Insert the new booking
    INSERT INTO Bookings (BookingID, TournamentID, UserID, BookType, BookApprStatus, BCreatedAt, BUpdatedAt)
    VALUES (@BookingID, NULL, @UserID, 'Individual', NULL, GETDATE(), NULL);

    PRINT 'Booking created successfully.';
END;

------------------------------------------------------------------------------------
-- Create Participant
CREATE PROCEDURE SP_CreateParticipant
	@BookingID nvarchar(10),
	@PFullName nvarchar(100),
	@PPhone nvarchar(20)
AS
BEGIN
	DECLARE @ParticipantsID nvarchar(10);
	DECLARE @TotalCapacity int;
	DECLARE @CurrentParticipantsCount int;

    IF NOT EXISTS (SELECT 1 FROM Bookings WHERE BookingID = @BookingID)
    BEGIN
        RAISERROR ('Booking does not exist.', 16, 1);
        RETURN;
    END;

    -- Calculate the total capacity for the BookingID
    SELECT @TotalCapacity = SUM(f.Capacity * SlotCount)
    FROM (
        SELECT fs.FacilityID, COUNT(*) AS SlotCount
        FROM FacilitiesSlot fs
        WHERE fs.BookingID = @BookingID
        GROUP BY fs.FacilityID
    ) AS FacilitySlotCounts
    JOIN Facilities f ON FacilitySlotCounts.FacilityID = f.FacilityID;

    -- Validate that the BookingID has booked slots
    IF @TotalCapacity IS NULL OR @TotalCapacity = 0
    BEGIN
        RAISERROR ('This booking has no booked slots.', 16, 1);
        RETURN;
    END;

    -- Count the current number of participants for the booking
    SELECT @CurrentParticipantsCount = COUNT(*)
    FROM Participants
    WHERE BookingID = @BookingID;

    -- Check if the capacity has been exceeded
    IF @CurrentParticipantsCount >= @TotalCapacity
    BEGIN
        RAISERROR ('Maximum capacity for this booking has been reached.', 16, 1);
        RETURN;
    END;

	-- Auto-generate ParticipantsID (e.g., P001, P002)
    SELECT @ParticipantsID = 'P' + RIGHT('000' + CAST(ISNULL(MAX(CAST(SUBSTRING(ParticipantsID, 2, LEN(ParticipantsID)) AS INT)), 0) + 1 AS NVARCHAR), 3)
    FROM Participants;

    INSERT INTO Participants (ParticipantsID, BookingID, PFullName, PPhone, PCreatedAt)
    VALUES (@ParticipantsID, @BookingID, @PFullName, @PPhone, GETDATE());

	    -- Update the current participants count
    SELECT @CurrentParticipantsCount = COUNT(*)
    FROM Participants
    WHERE BookingID = @BookingID;

    -- Print the number of participants and remaining capacity
    PRINT 'Participant has been successfully added.';
    PRINT 'Total Participants in Booking ' + @BookingID + ': ' + CAST(@CurrentParticipantsCount AS nvarchar);
    PRINT 'Remaining Capacity: ' + CAST(@TotalCapacity - @CurrentParticipantsCount AS nvarchar);
END;

------------------------------------------------------------------------------------
-- Update Participant 
CREATE PROCEDURE SP_UpdateParticipant
    @ParticipantsID NVARCHAR(10), 
    @PFullName NVARCHAR(100) = NULL, 
    @PPhone NVARCHAR(20) = NULL 
AS
BEGIN
    IF NOT EXISTS (
		SELECT 1 FROM Participants P
		INNER JOIN Bookings B ON P.BookingID = B.BookingID AND P.ParticipantsID = @ParticipantsID
		WHERE B.UserID = (SELECT U.UserID FROM UserLoginDetails U WHERE U.LoginName = USER_NAME())
		--B.UserID IN (SELECT U.UserID FROM Users U WHERE U.UType = 'IndividualCustomer')
    )
	
    BEGIN
        THROW 50001, 'Participant does not exist or does not belong to the customer.', 1;
    END;

    UPDATE Participants
    SET 
        PFullName = COALESCE(@PFullName, PFullName),
        PPhone = COALESCE(@PPhone, PPhone),
        PUpdatedAt = GETDATE()
    WHERE ParticipantsID = @ParticipantsID;
END

------------------------------------------------------------------------------------
-- Delete Participants
CREATE PROCEDURE SP_DeleteParticipant
    @ParticipantsID NVARCHAR(10)
AS
BEGIN
    IF NOT EXISTS (
		SELECT 1 FROM Participants P
		INNER JOIN Bookings B ON P.BookingID = B.BookingID AND P.ParticipantsID = @ParticipantsID
		WHERE B.UserID = (SELECT U.UserID FROM UserLoginDetails U WHERE U.LoginName = USER_NAME())
    )
	
    BEGIN
        THROW 50001, 'Participant does not exist or does not belong to the customer.', 1;
    END;

    DELETE Participants
	FROM Participants P
    WHERE P.ParticipantsID = @ParticipantsID;
END

------------------------------------------------------------------------------------
-- Book Facility Slot
CREATE PROCEDURE SP_BookFacilitiesSlots
	@BookingID nvarchar(10),
	@FacilitySlotIDs nvarchar(max) --comma-separated list of slot IDs
AS
BEGIN
	DECLARE @TournamentID nvarchar(10);
    DECLARE @StartTourTime datetime;
    DECLARE @EndTourTime datetime;
	DECLARE @FacilityCount int;
	DECLARE @BookStatus nvarchar(20);

    -- Validate BookingID
    IF NOT EXISTS (SELECT 1 FROM Bookings WHERE BookingID = @BookingID)
    BEGIN
        RAISERROR ('Invalid BookingID.', 16, 1);
        RETURN;
    END;

    -- Get the current Booking Status
    SELECT @BookStatus = BookApprStatus
    FROM Bookings
    WHERE BookingID = @BookingID;

    -- Prevent additional bookings if the booking status is 'Approved'
    IF @BookStatus = 'Approved'
    BEGIN
        RAISERROR ('No further slots can be booked as this booking is already approved.', 16, 1);
        RETURN;
    END;

    IF @BookStatus = 'Booked'
    BEGIN
        RAISERROR ('No further slots can be booked as this booking is already completed for an individual customer.', 16, 1);
        RETURN;
    END;

    -- Reset the Booking Status to 'Pending' if it was 'Rejected'
    IF @BookStatus = 'Rejected'
    BEGIN
        UPDATE Bookings
        SET BookApprStatus = 'Pending'
        WHERE BookingID = @BookingID;
    END;

    -- Get TournamentID from the Booking
    SELECT @TournamentID = TournamentID
    FROM Bookings
    WHERE BookingID = @BookingID;

 -- Scenario 1: Tournament Booking
    IF @TournamentID IS NOT NULL
    BEGIN
        -- Get Tournament Start and End Times
        SELECT @StartTourTime = StartTourTime, @EndTourTime = EndTourTime
        FROM Tournaments
        WHERE TournamentID = @TournamentID;

        -- Validate Facility Slots Time Range
        IF EXISTS (SELECT 1 FROM FacilitiesSlot WHERE FacilitySlotID IN (SELECT value FROM STRING_SPLIT(@FacilitySlotIDs, ','))
              AND (StartSlotTime < @StartTourTime OR EndSlotTime > @EndTourTime)
        )
        BEGIN
            RAISERROR ('One or more selected slots are outside the tournament time range.', 16, 1);
            RETURN;
        END;

		-- Lock the selected slots
		UPDATE FacilitiesSlot
		SET FaciStatus = 'Locked', BookingID = @BookingID
		WHERE FacilitySlotID IN (SELECT value FROM STRING_SPLIT(@FacilitySlotIDs, ','));

		PRINT 'Facility slots have been successfully locked for the booking.';
		PRINT 'Waiting for approved.';
    END
    ELSE
    BEGIN
        -- Scenario 2: Individual Customer Booking
        -- Validate Facility Slots belong to a single facility
        SELECT @FacilityCount = COUNT(DISTINCT FacilityID)
        FROM FacilitiesSlot
        WHERE FacilitySlotID IN (SELECT value FROM STRING_SPLIT(@FacilitySlotIDs, ','));

        IF @FacilityCount > 1
        BEGIN
            RAISERROR ('Individual bookings can only book slots from a single facility.', 16, 1);
            RETURN;
        END;

		-- Check if any selected slot is already locked
		IF EXISTS (SELECT 1 FROM FacilitiesSlot WHERE FacilitySlotID IN (SELECT value FROM STRING_SPLIT(@FacilitySlotIDs, ','))
				AND FaciStatus = 'Locked'
		)
		BEGIN
			RAISERROR ('One or more selected slots are already locked by another user.', 16, 1);
			RETURN;
		END;

		-- Update from 'Available' to 'Unavailable'
		UPDATE FacilitiesSlot
		SET FaciStatus = 'Unavailable', BookingID = @BookingID
		WHERE FacilitySlotID IN (SELECT value FROM STRING_SPLIT(@FacilitySlotIDs, ','));

		UPDATE Bookings
		SET BookApprStatus = 'Booked'
		WHERE BookingID = @BookingID;

		DECLARE @TotalAmount decimal(10,2);
		SELECT @TotalAmount = SUM(CAST(Cost AS decimal(10,2)))
		FROM FacilitiesSlot
		WHERE BookingID = @BookingID;

		-- Generate a new TransactionID
		DECLARE @TransactionID NVARCHAR(10);
		SET @TransactionID = 'TR' + RIGHT('000' + CAST((SELECT COUNT(*) + 1 FROM Transactions) AS NVARCHAR), 3);

		-- Insert the new transaction
		INSERT INTO Transactions (TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp)
		VALUES (@TransactionID, @BookingID, NULL, 'Pending', @TotalAmount, NULL);

		PRINT 'Facility slots have been successfully booked for the individual customer.';
	END;
END;
------------------------------------------------------------------------------------
-- Approve Booking
CREATE PROCEDURE SP_ApproveBooking
	@BookingID nvarchar(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Bookings WHERE BookingID = @BookingID)
    BEGIN
        RAISERROR ('Booking does not exist.', 16, 1);
        RETURN;
    END;

    -- Validate that the BookingID has locked slots in the FacilitiesSlot table
    IF NOT EXISTS (
        SELECT 1 
        FROM FacilitiesSlot 
        WHERE BookingID = @BookingID AND FaciStatus = 'Locked'
    )
    BEGIN
        RAISERROR ('Booking cannot be approved because no slots have been locked for this BookingID.', 16, 1);
        RETURN;
    END;

	UPDATE Bookings
	SET BookApprStatus = 'Approved' 
	WHERE BookingID = @BookingID;

    -- Update FaciStatus to 'Unavailable' for the associated slots
    UPDATE FacilitiesSlot
    SET FaciStatus = 'Unavailable'
    WHERE BookingID = @BookingID;

	DECLARE @TotalAmount decimal(10,2);
	SELECT @TotalAmount = SUM(CAST(Cost AS decimal(10,2)))
	FROM FacilitiesSlot
	WHERE BookingID = @BookingID;

    -- Generate a new TransactionID
    DECLARE @TransactionID NVARCHAR(10);
    SET @TransactionID = 'TR' + RIGHT('000' + CAST((SELECT COUNT(*) + 1 FROM Transactions) AS NVARCHAR), 3);

    -- Insert the new transaction
    INSERT INTO Transactions (TransactionID, BookingID, PaymentCard, TransStatus, TotalAmount, PaymentTimestamp)
    VALUES (@TransactionID, @BookingID, NULL, 'Pending', @TotalAmount, NULL);

	PRINT 'Booking has been approved successfully.';
END;

------------------------------------------------------------------------------------
-- Reject Booking
CREATE PROCEDURE SP_RejectBooking
	@BookingID nvarchar(10)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Bookings WHERE BookingID = @BookingID)
    BEGIN
        RAISERROR ('Booking does not exist.', 16, 1);
        RETURN;
    END;

    -- Validate that the BookingID has booked slots in the FacilitiesSlot table
    IF NOT EXISTS (SELECT 1 FROM FacilitiesSlot WHERE BookingID = @BookingID)
    BEGIN
        RAISERROR ('This booking cannot be rejected because no slots have been locked for this BookingID.', 16, 1);
        RETURN;
    END;

	UPDATE Bookings
	SET BookApprStatus = 'Rejected'
	WHERE BookingID = @BookingID;

    UPDATE FacilitiesSlot
    SET FaciStatus = 'Available', BookingID = NULL
    WHERE BookingID = @BookingID;

	PRINT 'Booking has been rejected';
END;

-- Make Payment
CREATE PROCEDURE SP_MakePayment
	@BookingID nvarchar(10),
	@PaymentCard nvarchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Transactions WHERE BookingID = @BookingID)
    BEGIN
        RAISERROR ('Transaction does not exist.', 16, 1);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM Transactions WHERE BookingID = @BookingID AND TransStatus = 'Completed')
    BEGIN
        RAISERROR ('Payment cannot be processed. The transaction is already completed.', 16, 1);
        RETURN;
    END;

	-- Update the transaction with the payment details
    UPDATE Transactions
    SET PaymentCard = @PaymentCard,
        TransStatus = 'Completed',
        PaymentTimestamp = GETDATE()
    WHERE BookingID = @BookingID;
	
	PRINT 'Payment has been processed succesfully.';
END;

--------------------------------------------------------------------------------------
CREATE PROCEDURE SP_OrganizersDetails
	@UserID nvarchar(10),
	@BusinessName nvarchar(100),
	@OrgApprStatus nvarchar(10) = 'Pending' -- Default to 'Pending'
AS
BEGIN
    -- Check if UserID exists in the table
    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID AND UType = 'TournamentOrganizer')
    BEGIN
        RAISERROR ('UserID does not exist / UType is not Organizer.', 16, 1);
        RETURN;
    END;
 
    -- Insert Organizer details
    IF EXISTS (SELECT 1 FROM Organizers WHERE UserID = @UserID)
    BEGIN
        -- Update existing Organizer details
        UPDATE Organizers
        SET 
            BusinessName = @BusinessName
        WHERE UserID = @UserID;
    END
    ELSE
    BEGIN
        -- Insert new Organizer details
        INSERT INTO Organizers (UserID, BusinessName)
        VALUES (@UserID, @BusinessName);
    END;
END;









