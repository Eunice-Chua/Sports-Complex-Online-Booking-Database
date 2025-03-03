EXECUTE AS LOGIN = 'auditor1';

REVERT;

SELECT USER_NAME() AS CurrentUser;

use AP_Arena
SELECT * FROM BookingsAudit;
SELECT * FROM FacilitiesSlotAudit;
SELECT * FROM ParticipantsAudit;
SELECT * FROM TournamentsAudit;
SELECT * FROM UsersHistory;
SELECT * FROM UserLoginDetailsHistory;
SELECT * FROM TournamentsAudit;
SELECT * FROM FacilitiesHistory;
SELECT * FROM OrganizersHistory;

use master
SELECT * FROM DMLAuditLogView ORDER BY event_time DESC; -- Display the most recent events first
SELECT * FROM DDLAuditLogView ORDER BY event_time DESC; -- Display the most recent events first
SELECT * FROM LoginAuditLogView ORDER BY event_time DESC; -- Display the most recent events first
SELECT * FROM DCLAuditLogView ORDER BY event_time DESC; -- Display the most recent events first

