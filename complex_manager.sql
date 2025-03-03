USE AP_Arena

EXECUTE AS LOGIN = 'manager1';

REVERT;

SELECT USER_NAME() AS CurrentUser;

SELECT * FROM dbo.Users;
SELECT * FROM dbo.UserLoginDetails;
SELECT * FROM dbo.Tournaments;
SELECT * FROM dbo.Facilities;
SELECT * FROM dbo.FacilitiesSlot;
SELECT * FROM dbo.Participants;
SELECT * FROM dbo.Bookings;


-- 1. can view and update their own details but cannot delete them. 

-- view own details
SELECT * FROM dbo.view_own_details;

-- Update own details
EXEC dbo.SP_UpdateCurrentUser @UserID = 'U005', @UEmail = 'adaee@gmail.com';

-- Not able to update other details
EXEC dbo.SP_UpdateCurrentUser @UserID = 'U001', @UEmail = 'adaaa@gmail.com';

-- Not able to delete
DELETE FROM dbo.Users WHERE UserID = 'U005';

-- View other users details (Tournament Organizer, Individual Customer) that registered in the system 
SELECT * FROM dbo.view_other_users;

-- View particpants
SELECT * FROM dbo.view_participants_manager;

-- to approve Tournament Organizer registeration
SELECT * FROM dbo.Organizers;
EXEC dbo.SP_ApproveOrganizer 'U001'

-- to reject Tournament Organizer registeration
EXEC dbo.SP_RejectOrganizer 'U001'

-- can create facilities
SELECT * FROM dbo.Facilities;
EXEC dbo.SP_CreateFacility 'Volleyball Court 5', '4'

-- can remove facilities
DELETE FROM dbo.Facilities
WHERE FacilityID = 'V005'

-- can create facilities slot
SELECT * FROM dbo.FacilitiesSlot;
EXEC dbo.SP_CreateFacilitiesSlot 'V004', '1/2/25 1:00PM', '1/2/25 2:00PM', '23.9'

-- update facilities slot (change FaciStatus to unavailable - after approve)
SELECT * FROM dbo.FacilitiesSlot;
UPDATE dbo.FacilitiesSlot
SET FaciStatus = 'Unavailable'
WHERE FacilitySlotID = 'FS005';

-- can approve booking (tournament + facility slot) - only tournament need approval, individual booking no need approval
SELECT * FROM Bookings
EXEC SP_ApproveBooking 'B001'

-- if no slot have been locked for this BookingID - then the booking cannot be approved
SELECT * FROM Bookings
EXEC SP_ApproveBooking 'B003'

-- can reject facility booking based on tournament (booking)
EXEC SP_RejectBooking 'B001'

-- can delete booking
SELECT * FROM Bookings
DELETE FROM Bookings WHERE BookingID='B008'


