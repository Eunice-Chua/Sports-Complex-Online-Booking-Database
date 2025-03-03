USE AP_Arena

EXECUTE AS LOGIN = 'admin1';

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

-- Can create accounts for Complex Manager, Tournament Organizer, Individual Customer and Participants. 
SELECT * FROM dbo.Users;
SELECT * FROM dbo.UserLoginDetails;

EXEC dbo.SP_CreateLogin 'U006', 'managertest', 'managertest', 'managerttt', 'ComplexManager';

-- Can add and manage (update & delete) the Complex Manager. 
EXEC dbo.SP_InsertUsers 'yuki', 'yukichew@gmail.com', '0282212198', 'ComplexManager'

UPDATE dbo.Users
SET UEmail = 'yuki123@gmail.com'
WHERE UserID = 'U007'

DELETE FROM dbo.Users WHERE UserID = 'U007';


-- perform permission management (grant & deny) for Complex Manager, Tournament Organizer, Individual Customer and Participants. 
-- For Complex Manager 
-- table
DENY UPDATE ON dbo.Users TO ComplexManager;
GRANT SELECT ON dbo.Users TO ComplexManager;
DENY DELETE ON dbo.Users TO ComplexManager;
DENY SELECT ON dbo.UserLoginDetails TO ComplexManager;
GRANT SELECT ON dbo.Participants To ComplexManager;
GRANT SELECT ON dbo.Organizers TO ComplexManager;
GRANT SELECT, DELETE ON dbo.Bookings TO ComplexManager;
GRANT SELECT, UPDATE, DELETE ON dbo.Facilities TO ComplexManager;
GRANT SELECT, UPDATE, DELETE ON dbo.FacilitiesSlot TO ComplexManager;
-- stored precedure
GRANT EXECUTE ON dbo.SP_UpdateCurrentUser TO ComplexManager;
GRANT EXECUTE ON dbo.SP_ApproveOrganizer TO ComplexManager;
GRANT EXECUTE ON dbo.SP_RejectOrganizer TO ComplexManager;
GRANT EXECUTE ON dbo.SP_CreateFacility TO ComplexManager;
GRANT EXECUTE ON dbo.SP_CreateFacilitiesSlot TO ComplexManager;
GRANT EXECUTE ON dbo.SP_ApproveBooking TO ComplexManager;
GRANT EXECUTE ON dbo.SP_RejectBooking TO ComplexManager;
-- view
GRANT SELECT ON dbo.view_own_details TO ComplexManager;

-- For Tournament Organizer
-- table
GRANT SELECT ON dbo.Users TO TournamentOrganizer;
DENY SELECT ON dbo.UserLoginDetails TO TournamentOrganizer;
GRANT SELECT ON dbo.Facilities TO TournamentOrganizer;
GRANT SELECT ON dbo.FacilitiesSlot TO TournamentOrganizer;
-- stored procedure
GRANT EXECUTE ON dbo.SP_UpdateCurrentUser TO TournamentOrganizer;
GRANT EXECUTE ON dbo.SP_CreateTournament TO TournamentOrganizer;
GRANT EXECUTE ON dbo.SP_CreateParticipant TO TournamentOrganizer;
GRANT EXECUTE ON dbo.SP_UpdateParticipant TO TournamentOrganizer;
GRANT EXECUTE ON dbo.SP_DeleteParticipant TO TournamentOrganizer;
GRANT EXECUTE ON dbo.SP_BookFacilitiesSlots TO TournamentOrganizer;
GRANT EXECUTE ON dbo.SP_MakePayment TO TournamentOrganizer;
GRANT EXECUTE ON SP_OrganizersDetails TO TournamentOrganizer;

-- view
GRANT SELECT ON dbo.view_participants TO TournamentOrganizer;
GRANT SELECT ON dbo.view_tournament_current_user TO TournamentOrganizer;
GRANT SELECT ON dbo.view_booking TO TournamentOrganizer;
GRANT SELECT ON dbo.view_transactions TO TournamentOrganizer;
GRANT SELECT ON dbo.view_unpaid_transactions TO TournamentOrganizer;

-- For Individual Customer
-- table
GRANT SELECT, UPDATE ON dbo.Users TO IndividualCustomer;
GRANT SELECT ON dbo.Facilities TO IndividualCustomer;
GRANT SELECT ON dbo.FacilitiesSlot TO IndividualCustomer;
-- stored procedure
GRANT EXECUTE ON dbo.SP_UpdateCurrentUser TO IndividualCustomer;
GRANT EXECUTE ON dbo.SP_CreateParticipant TO IndividualCustomer;
GRANT EXECUTE ON dbo.SP_UpdateParticipant TO IndividualCustomer;
GRANT EXECUTE ON dbo.SP_BookFacilitiesSlots TO IndividualCustomer;
GRANT EXECUTE ON dbo.SP_CreateBooking TO IndividualCustomer;
GRANT EXECUTE ON dbo.SP_MakePayment TO IndividualCustomer;
-- view
GRANT SELECT ON dbo.view_own_details TO IndividualCustomer;
GRANT SELECT ON dbo.view_participants TO IndividualCustomer;
GRANT SELECT ON dbo.view_booking TO IndividualCustomer;
GRANT SELECT ON dbo.view_transactions TO IndividualCustomer;
GRANT SELECT ON dbo.view_unpaid_transactions TO IndividualCustomer;

