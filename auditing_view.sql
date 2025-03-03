-- Create View to get DML audit logs -------------------------------------------------------------
CREATE VIEW DMLAuditLogView AS
SELECT
    event_time,                              -- Timestamp of the event
    class_type,                              -- Type of database object or event
    action_id,                               -- Type of action
    object_name,                             -- Name of the object being accessed
    database_name,                           -- Name of the database
    statement,                               -- The actual SQL statement executed
    succeeded,                               -- Indicates whether the action succeeded (1 = success)
    session_server_principal_name,            -- Name of the user or service that executed the action
	server_principal_name
FROM sys.fn_get_audit_file (
        'C:\SQL_SERVER_LOG\DML_CHANGES\*', -- Path to your audit files
        DEFAULT,
        DEFAULT
    )
WHERE database_name = 'AP_Arena'

GO
-- Create View to get DDL audit logs -------------------------------------------------------------
CREATE VIEW DDLAuditLogView AS
SELECT
    event_time,                              -- Timestamp of the event
    class_type,                              -- Type of database object or event
    action_id,                               -- Type of action
    database_name,                           -- Name of the database
    object_name,                             -- Name of the object being accessed
    statement,                               -- The actual SQL statement executed
    succeeded,                               -- Indicates whether the action succeeded (1 = success)
    session_server_principal_name,            -- Name of the user or service that executed the action
	server_principal_name
FROM sys.fn_get_audit_file (
        'C:\SQL_SERVER_LOG\DDL_CHANGES\*', -- Path to audit files
        DEFAULT,
        DEFAULT
    )
WHERE database_name = '' OR database_name = 'AP_Arena'

GO
-- Create View to get Login audit logs -------------------------------------------------------------
CREATE VIEW LoginAuditLogView AS
SELECT DISTINCT
    event_time,                              -- Timestamp of the event
    class_type,                              -- Type of database object or event
    action_id,                               -- Type of action
    succeeded,                               -- Indicates whether the action succeeded (1 = success)
    session_server_principal_name,           -- Name of the session-level user or service
    server_principal_name,                   -- Name of the server-level principal
    server_instance_name,                    -- Name of the SQL Server instance
    application_name,                        -- Name of the application connecting to the server
    statement                                -- The actual SQL statement executed
FROM sys.fn_get_audit_file (
        'C:\SQL_SERVER_LOG\LOGIN_ATTEMPT\*', -- Path to audit files
        DEFAULT,
        DEFAULT
    )
WHERE server_principal_name NOT LIKE 'NT SERVICE%'   -- Exclude NT SERVICE accounts
  AND server_principal_name NOT LIKE '%LAPTOP%'      -- Exclude accounts containing LAPTOP



GO
-- Query to get DCL audit logs ------------------------------------------------------------------------
CREATE VIEW DCLAuditLogView AS
SELECT
    event_time,                              -- Timestamp of the event
    class_type,                              -- Type of database object or event
    action_id,                               -- Type of action
    database_name,                           -- Name of the database
    object_name,                             -- Name of the object being accessed
    statement,                               -- The actual SQL statement executed
    succeeded,                               -- Indicates whether the action succeeded (1 = success)
    session_server_principal_name            -- Name of the user or service that executed the action
	server_principal_name
FROM sys.fn_get_audit_file (
        'C:\SQL_SERVER_LOG\DCL_CHANGES\*', -- Path to your audit files
        DEFAULT,
        DEFAULT
    )

GO
SELECT * FROM DMLAuditLogView ORDER BY event_time DESC; -- Display the most recent events first
SELECT * FROM DDLAuditLogView ORDER BY event_time DESC; -- Display the most recent events first
SELECT * FROM LoginAuditLogView ORDER BY event_time DESC; -- Display the most recent events first
SELECT * FROM DCLAuditLogView ORDER BY event_time DESC; -- Display the most recent events first
EXECUTE AS LOGIN = 'admin1';

REVERT;

SELECT USER_NAME() AS CurrentUser;
