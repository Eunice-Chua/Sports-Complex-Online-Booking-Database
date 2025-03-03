USE AP_Arena
SELECT USER_NAME() AS CurrentUser;

-- Security Policy
CREATE SCHEMA Security;

CREATE FUNCTION Security.fn_FilterUserAccess(@UserID NVARCHAR(10))
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (
    SELECT 1 AS AccessGranted
    FROM dbo.Users U
    WHERE @UserID = (SELECT UL.UserID FROM dbo.UserLoginDetails UL 
	WHERE UL.LoginName = USER_NAME())  OR USER_NAME() = 'admin1' or USER_NAME() = 'admin2' or USER_NAME() = 'dbo' or USER_NAME() = 'manager1' or USER_NAME() = 'manager2'
);

CREATE SECURITY POLICY UserSecurityPolicy
ADD FILTER PREDICATE Security.fn_FilterUserAccess(UserID)
ON dbo.Users
WITH (STATE = ON);


--DROP SECURITY POLICY UserSecurityPolicy;
--DROP FUNCTION Security.fn_FilterUserAccess;

SELECT * FROM sys.security_policies;



