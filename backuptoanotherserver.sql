-- RESTORE DATABASE ON OTHER SERVER
USE master

-- Restore Certificate Backup Cert
Create CERTIFICATE BackUpCert
From FILE = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\BackUpCert.cert'
WITH PRIVATE KEY (
    FILE = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\BackUpCert.key', 
DECRYPTION BY PASSWORD = 'QWEqwe!@#123'
);

-- Restore TDE Backup Cert
CREATE CERTIFICATE CertForTDE
FROM FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\CertForTDE.cert'
WITH PRIVATE KEY (
    FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\CertForTDE.key',
    DECRYPTION BY PASSWORD = 'QWEqwe!@#123'
);

-- Show Cert
SELECT name, thumbprint
FROM sys.certificates;

-- Restore Full Backup
RESTORE DATABASE [AP_Arena]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\FULL_BACKUPS\AP_Arena_full_20250119.bak'
WITH 
    MOVE 'AP_Arena' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\AP_Arena.mdf',
    MOVE 'AP_Arena_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\DATA\AP_Arena_log.ldf',
    NORECOVERY;

-- Restore Differential Backup
RESTORE DATABASE [AP_Arena]  
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\DIFFERENTIAL_BACKUPS\AP_Arena_differential_20250119.bak'
WITH NORECOVERY;  

-- Restore Transactional Log Backup
RESTORE LOG [AP_Arena]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER01\MSSQL\Backup\T_LOGS\AP_Arena_LogBackup_2025011919.trn'
WITH RECOVERY;

-- Show Database
USE AP_Arena
SELECT * FROM Users;
SELECT * FROM UserLoginDetails;
SELECT * FROM Tournaments;
SELECT * FROM Facilities;
SELECT * FROM FacilitiesSlot;
SELECT * FROM Participants;
SELECT * FROM Bookings;
SELECT * FROM Organizers;
SELECT * FROM Transactions;