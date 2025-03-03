USE AP_Arena

EXECUTE AS LOGIN = 'customer1';

REVERT;

SELECT USER_NAME() AS CurrentUser;

SELECT * FROM dbo.Users;
SELECT * FROM dbo.UserLoginDetails;
SELECT * FROM dbo.Tournaments;
SELECT * FROM dbo.Facilities;
SELECT * FROM dbo.FacilitiesSlot;
SELECT * FROM dbo.Participants;
SELECT * FROM dbo.Bookings;
SELECT * FROM dbo.Organizers;
SELECT * FROM dbo.Transactions;

-- view own details
--SELECT * FROM dbo.view_own_details;
SELECT * FROM dbo.Users;

-- Update own details
EXEC dbo.SP_UpdateCurrentUser @UserID = 'U003', @UFullName = 'Iris Tan', @UEmail = 'celine@gmail.com';

-- Not able to update other details
EXEC dbo.SP_UpdateCurrentUser @UserID = 'U001', @UEmail = 'adaaa@gmail.com';

-- Can register participants
EXEC SP_CreateParticipant 'B006', 'John Liew', '123456789'
EXEC SP_CreateParticipant 'B006', 'Yuki Liew', '123456789'
EXEC SP_CreateParticipant 'B006', 'John Liew', '123456789'
EXEC SP_CreateParticipant 'B006', 'Danny Liew', '123456789'

-- able to view participants details
SELECT * FROM dbo.view_participants;

-- Able to update participants’ details submitted under his/her booking
EXEC dbo.SP_UpdateParticipant 
    @ParticipantsID = 'P005', 
    @PFullName = 'Johnne Tan';

-- Not able to update participants’ details submitted under his/her booking
EXEC dbo.SP_UpdateParticipant 
    @ParticipantsID = 'P001', 
    @PFullName = 'Johnnne Tan';

-- Can view the facility, cannot update and delete
SELECT * FROM dbo.Facilities;

-- Can view the facility slot, cannot update and delete
SELECT * FROM dbo.FacilitiesSlot;

-- can book facility slot needed for the event
EXEC SP_BookFacilitiesSlots @BookingID = 'B006', 
							@FacilitySlotIDs  = 'FS006'

-- Make Booking
EXEC dbo.SP_CreateBooking @UserID = 'U003'

-- Check their own booking
SELECT * FROM dbo.view_booking;

-- Make Payment
EXEC dbo.SP_MakePayment 'B002', '0092988278'

-- View their transactions
OPEN SYMMETRIC KEY CLE_SYMMETRIC_USER
	DECRYPTION BY CERTIFICATE SYMMETRIC_ENCRYPTION_CERT;
GO
SELECT * FROM dbo.view_transactions;

-- View Unpaid Booking
SELECT * FROM dbo.view_unpaid_transactions;