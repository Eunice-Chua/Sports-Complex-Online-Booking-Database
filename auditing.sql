----------------------------------------------------------------------------------
-- DROP AUDIT
ALTER SERVER AUDIT SPECIFICATION[TrackDDLChanges]
WITH (STATE = OFF);
GO
ALTER SERVER AUDIT [TrackDDLChanges]
WITH (STATE = OFF);
GO
DROP SERVER AUDIT SPECIFICATION [TrackDDLChanges]
DROP SERVER AUDIT [TrackDDLChanges]
use MASTER

-----------------------------------------------------------------------------------
-- TRACK DCL CHANGES
CREATE SERVER AUDIT [TrackDCLChanges]
TO FILE (FILEPATH = N'C:\SQL_SERVER_LOG\DCL_CHANGES\')

ALTER SERVER AUDIT [TrackDCLChanges]
WITH (STATE = ON);

CREATE SERVER AUDIT SPECIFICATION [TrackDCLChanges]
FOR SERVER AUDIT [TrackDCLChanges]
ADD (DATABASE_PERMISSION_CHANGE_GROUP),      -- Captures DCL changes: GRANT/DENY/REVOKE at the database level
ADD (SERVER_PERMISSION_CHANGE_GROUP)         -- Captures DCL changes: GRANT/DENY/REVOKE at the server level
WITH (STATE = ON);

-----------------------------------------------------------------------------------
-- TRACK DDL CHANGES
CREATE SERVER AUDIT [TrackDDLChanges]
TO FILE (FILEPATH = N'C:\SQL_SERVER_LOG\DDL_CHANGES\')

ALTER SERVER AUDIT [TrackDDLChanges]
WITH (STATE = ON);

CREATE SERVER AUDIT SPECIFICATION [TrackDDLChanges]
FOR SERVER AUDIT [TrackDDLChanges]
ADD (DATABASE_OBJECT_CHANGE_GROUP),
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (SERVER_OBJECT_CHANGE_GROUP)
WITH (STATE = ON);

-------------------------------------------------------------------------------
-- TRACK DML CHANGES
CREATE SERVER AUDIT [TrackDMLChanges]
TO FILE (FILEPATH = N'C:\SQL_SERVER_LOG\DML_CHANGES\')
GO

ALTER SERVER AUDIT [TrackDMLChanges]
WITH (STATE = ON);
GO

USE AP_Arena;
CREATE DATABASE AUDIT SPECIFICATION AP_ArenaDMLChanges
FOR SERVER AUDIT TrackDMLChanges
ADD (INSERT, UPDATE, DELETE, SELECT
    ON DATABASE::[AP_Arena] BY public)
WITH (STATE = ON);
GO

-------------------------------------------------------------------------------
-- Track Login Sessions
CREATE SERVER AUDIT [TrackLogin]
TO FILE (FILEPATH = N'C:\SQL_SERVER_LOG\LOGIN_ATTEMPT\')
GO

ALTER SERVER AUDIT [TrackLogin]
WITH (STATE = ON);
GO

CREATE SERVER AUDIT SPECIFICATION [TrackLoginAttempt]
FOR SERVER AUDIT [TrackLogin]
ADD (FAILED_LOGIN_GROUP),
ADD (LOGIN_CHANGE_PASSWORD_GROUP),
ADD (LOGOUT_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON);
