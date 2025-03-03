-- TDE
-- Step 1: Create the Master Key and Certificate
USE master;
GO

-- Create Master Key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QWEqwe!@#123';
GO

-- Create Certificate for TDE
CREATE CERTIFICATE CertForTDE WITH SUBJECT = 'CertForTDE';
GO

-- Step 2: Set up Database Encryption Key and Enable TDE
USE AP_Arena;
GO

CREATE DATABASE ENCRYPTION KEY 
WITH ALGORITHM = AES_256 
ENCRYPTION BY SERVER CERTIFICATE CertForTDE;
GO

-- Step 3: Enable Encryption on the Database
ALTER DATABASE AP_Arena 
SET ENCRYPTION ON;
GO

-- Check Encryption Status
USE master
SELECT
    db_name(a.database_id) AS DBName,
    a.encryption_state AS EncryptionState,
    CASE
        WHEN a.encryption_state = 0 THEN 'No encryption'
        WHEN a.encryption_state = 1 THEN 'Unencrypted'
        WHEN a.encryption_state = 2 THEN 'Encryption in progress'
        WHEN a.encryption_state = 3 THEN 'Encrypted'
        WHEN a.encryption_state = 4 THEN 'Key change in progress'
        WHEN a.encryption_state = 5 THEN 'Decryption in progress'
        ELSE 'Unknown'
    END AS EncryptionStateDescription,
    a.encryptor_type,
    b.name AS 'DEK Encrypted By'
FROM
    sys.dm_database_encryption_keys a
INNER JOIN sys.certificates b ON a.encryptor_thumbprint = b.thumbprint
GO

---------------------------------------------------------------------------------
-- Encryption (PaymentCard)

-- Step 1: Create master key encrytion key(DEK) at AP_Arena
USE AP_Arena
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'QWEqwe!@#123'

-- Step 2: Create a certificate at database level
USE AP_Arena
CREATE CERTIFICATE SYMMETRIC_ENCRYPTION_CERT WITH SUBJECT ='SYMMETRIC_ENCRYPTION_CERT';

CREATE SYMMETRIC KEY CLE_SYMMETRIC_USER
	WITH ALGORITHM = AES_256
	ENCRYPTION BY CERTIFICATE SYMMETRIC_ENCRYPTION_CERT;

-- Step 3: Create a symmetric ky protected by the cert
OPEN SYMMETRIC KEY CLE_SYMMETRIC_USER
	DECRYPTION BY CERTIFICATE SYMMETRIC_ENCRYPTION_CERT;
GO

-- List all symmetric keys
USE AP_Arena
SELECT *FROM sys.symmetric_keys
GO

-- List all certificates
SELECT *FROM sys.certificates;
GO

-- Step 4: Update Payment Card Column to Encrypt
UPDATE Transactions
SET PaymentCard = EncryptByKey(Key_GUID('CLE_SYMMETRIC_USER'), PaymentCard)
WHERE TransactionID IS NOT NULL;

-- Check Encryption
SELECT *FROM Transactions

-- Grant permission to IndividualCustomer role to decrypt the key
GRANT CONTROL ON SYMMETRIC KEY::CLE_SYMMETRIC_USER TO IndividualCustomer;
GRANT CONTROL ON CERTIFICATE::SYMMETRIC_ENCRYPTION_CERT TO IndividualCustomer;

-- Grant permission to TournamentOrganizer role to decrypt the key
GRANT CONTROL ON SYMMETRIC KEY::CLE_SYMMETRIC_USER TO TournamentOrganizer;
GRANT CONTROL ON CERTIFICATE::SYMMETRIC_ENCRYPTION_CERT TO TournamentOrganizer;

---------------------------------------------------------------------------------
-- Dynamic Data Masking (User - Phone, Email, Name | Participant - Phone, Name)
USE AP_ARENA
GO

-- Make sure current user is dbo
SELECT CURRENT_USER

-- Add masking columns
ALTER TABLE Users  
ALTER COLUMN UPhone ADD MASKED WITH (FUNCTION = 'partial(0,"XXXXXX",4)');
GO

ALTER TABLE Users
ALTER COLUMN UEmail ADD MASKED WITH (FUNCTION = 'email()');
GO

ALTER TABLE Users
ALTER COLUMN UFullName ADD MASKED WITH (FUNCTION = 'partial(3, "XXXX", 0)');
GO

ALTER TABLE Participants
ALTER COLUMN PPhone ADD MASKED WITH (FUNCTION = 'partial(0,"XXXXXX",4)');
GO

ALTER TABLE Participants
ALTER COLUMN PFullName ADD MASKED WITH (FUNCTION = 'partial(3, "XXXX", 0)');
GO

-- Grant/Deny Permission
DENY UNMASK TO DataAdmin;
GRANT UNMASK TO TournamentOrganizer;
GRANT UNMASK TO IndividualCustomer;
DENY UNMASK ON Users(UFullName) TO ComplexManager;
DENY UNMASK ON Users(UEmail) TO ComplexManager;
GRANT UNMASK ON Users(UFullName) TO ComplexManager;
GRANT UNMASK ON Participants(PFullName) TO ComplexManager;
DENY UNMASK ON Participants(PPhone) TO ComplexManager;

-- GRANT UNMASK ON Users TO ComplexManager;
-- DENY UNMASK ON Participants TO ComplexManager;
GRANT UNMASK TO IndividualCustomer;

-- Check Current User Name
SELECT USER_NAME() AS CurrentUser;

-- Test Admin view
GRANT SHOWPLAN TO admin1;
EXECUTE AS LOGIN = 'admin1';
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Participants;
REVERT;

-- Test Manager View
GRANT SHOWPLAN TO manager1;
EXECUTE AS LOGIN = 'manager1';
SELECT * FROM dbo.view_own_details;
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Participants;
REVERT;

-- Test Organizer View
GRANT SHOWPLAN TO organizer1;
EXECUTE AS LOGIN = 'organizer1';
SELECT * FROM dbo.Users;
SELECT * FROM dbo.view_participants;
REVERT;

-- Test Customer View
GRANT SHOWPLAN TO customer1;
EXECUTE AS LOGIN = 'customer1';
SELECT * FROM dbo.Users;
SELECT * FROM dbo.view_participants;
REVERT;
---------------------------------------------------------------------------------
-- Hashing (Password)

-- Add PasswordHash column to UserLoginDetails
ALTER TABLE UserLoginDetails
ADD PasswordHash VARBINARY(64);
GO

-- Update Original Data
UPDATE UserLoginDetails
SET 
    PasswordHash = HASHBYTES('SHA2_512', CONCAT(UPassword, CAST(NEWID() AS VARCHAR(36))))
GO

-- Drop Password Table
ALTER TABLE UserLoginDetails
DROP COLUMN UPassword;

-- Check Table
SELECT *FROM UserLoginDetails
