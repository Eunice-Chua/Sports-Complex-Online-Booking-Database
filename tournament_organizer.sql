USE AP_Arena

EXECUTE AS LOGIN = 'organizer1';

REVERT;

SELECT USER_NAME() AS CurrentUser;

SELECT * FROM dbo.Users;
SELECT * FROM dbo.UserLoginDetails;
SELECT * FROM dbo.Tournaments;
SELECT * FROM dbo.Facilities;
SELECT * FROM dbo.FacilitiesSlot;
SELECT * FROM dbo.Participants;
SELECT * FROM dbo.Bookings;

-- view own details
SELECT * FROM dbo.Users;

-- Update own details
EXEC dbo.SP_UpdateCurrentUser @UserID = 'U001', @UFullName = 'EmilyOi', @UEmail = 'emily@gmail.com';

-- able to view participants details
SELECT * FROM dbo.view_participants;

-- Not able to update other details
EXEC dbo.SP_UpdateCurrentUser @UserID = 'U002', @UEmail = 'adaaa@gmail.com';

-- Delete participants
EXEC dbo.SP_DeleteParticipant @ParticipantsID = 'P004'

-- can create tournament event + auto generate booking with booking id that canbe used for facility booking
EXEC SP_CreateTournament 'U001', 'APU test', '1/7/25 3:00PM', '1/7/25 6:00PM';

-- Can register participants
EXEC SP_CreateParticipant 'B001', 'John Liew', '123456789'

-- Able to update participants’ details submitted under his/her booking
EXEC dbo.SP_UpdateParticipant 
    @ParticipantsID = 'P002', 
    @PFullName = 'Lisas Tan';

-- Not able to update participants’ details submitted under his/her booking
EXEC dbo.SP_UpdateParticipant 
    @ParticipantsID = 'P006', 
    @PFullName = 'Johnnne Tan';


-- Can view the tournament that they created
SELECT * FROM dbo.view_tournament_current_user;

-- Can view their own booking
SELECT * FROM dbo.view_booking;

-- Can view the facility, cannot update and delete
SELECT * FROM dbo.Facilities;

-- Can view the facility slot, cannot update and delete
SELECT * FROM dbo.FacilitiesSlot;

-- can book facility slot needed for the event
EXEC dbo.SP_BookFacilitiesSlots @BookingID = 'B001', 
							@FacilitySlotIDs  = 'FS003,FS004,FS005,FS006,FS007'

-- Make Payment
EXEC dbo.SP_MakePayment 'B001', '0092988278'

-- View their transactions
OPEN SYMMETRIC KEY CLE_SYMMETRIC_USER
	DECRYPTION BY CERTIFICATE SYMMETRIC_ENCRYPTION_CERT;
GO
SELECT * FROM dbo.view_transactions;

-- View Unpaid Booking
SELECT * FROM dbo.view_unpaid_transactions;