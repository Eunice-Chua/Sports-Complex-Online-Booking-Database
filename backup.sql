-- Backup
Use master
GO

-- Create Backup Certificate
CREATE CERTIFICATE BackUpCert
WITH SUBJECT = 'BackUpCert'
GO

-- Show Cert
SELECT name, thumbprint
FROM sys.certificates;

-- Backup Certificate
BACKUP CERTIFICATE BackUpCert 
TO FILE = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\BackUpCert.cert'
WITH PRIVATE KEY (
    FILE = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\BackUpCert.key', 
ENCRYPTION BY PASSWORD = 'QWEqwe!@#123'
);
Go

-- Create Full backups
DECLARE @FileName AS VARCHAR(50)
DECLARE @FilePath AS VARCHAR(255)
SET @FileName = ('AP_Arena_full_' + CONVERT(VARCHAR(30), GETDATE(), 112) + '.bak')
SET @FilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\FULL_BACKUPS\' + @FileName
PRINT @FilePath

BACKUP DATABASE [AP_Arena]
TO DISK = @FilePath
WITH
    DESCRIPTION = N'Full Backup for AP_Arena Database',
    FORMAT, -- MUST FORMAT IF ENCRYPTED (NEW BACKUP SET)
    INIT,
    MEDIANAME = N'AP_Arena_FULL_BACKUP',
    NAME = N'AP_Arena-Full Database Backup',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [BackUpCert]),
    STATS = 10
GO

-- CREATE DIFFERENTIAL BACKUP (DAILY)
DECLARE @FileName AS VARCHAR(50)
DECLARE @FilePath AS VARCHAR(255)
SET @FileName = ('AP_Arena_differential_' + CONVERT(VARCHAR(30), GETDATE(), 112) + '.bak')
SET @FilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\DIFFERENTIAL_BACKUPS\' + @FileName
PRINT @FilePath

BACKUP DATABASE [AP_Arena]
TO DISK = @FilePath
WITH
    DIFFERENTIAL,
    DESCRIPTION = N'Differential Backup for AP_Arena Database',
    NOFORMAT,
    NOINIT,
    NAME = N'AP_Arena-Differential Database Backup',
    SKIP,
    NOREWIND,
    NOUNLOAD,
    ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [BackUpCert]),
    STATS = 10
GO

-- BACKUP TRANSACTION LOG (MUST HAVE AT LEAST FULL BACKUP ONCE) - HOURLY
DECLARE @FileName AS VARCHAR(50)
DECLARE @FilePath AS VARCHAR(255)
SET @FileName = ('AP_Arena_LogBackup_' + CONVERT(VARCHAR(30), GETDATE(), 112) + LEFT(CONVERT(VARCHAR(30), GETDATE(), 108), 2) + '.trn')
SET @FilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\T_LOGS\' + @FileName
PRINT @FilePath

USE master
BACKUP LOG [AP_Arena]
TO DISK = @FilePath
WITH
    NOFORMAT,
    NOINIT,
    NAME = @FileName,
    NOSKIP,
    NOREWIND,
    NOUNLOAD,
    ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [BackUpCert]),
    STATS = 5
GO

-------------------------------------------------------------------------------------------------------------------------
-- SAME SERVER RESTORE (DROP DATABASE)

-- Drop Database
USE master
DROP DATABASE AP_Arena

-- Drop Backup Cert
DROP CERTIFICATE BackUpCert 

-- Restore Backup Cert
Create CERTIFICATE BackUpCert
From FILE = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\BackUpCert.cert'
WITH PRIVATE KEY (
    FILE = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\BackUpCert.key', 
DECRYPTION BY PASSWORD = 'QWEqwe!@#123'
);

-- RESTORE WITH FULL BACKUP (USE NORECOVERY IF YOU NEED DIFFERENTIAL BACKUP)
RESTORE DATABASE [AP_Arena]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\FULL_BACKUPS\AP_Arena_full_20250119.bak'
WITH
    FILE = 1,
    NORECOVERY,
    NOUNLOAD,
    STATS = 5
GO

-- RESTORE WITH DIFFERENTIAL BACKUP
RESTORE DATABASE [AP_Arena]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\DIFFERENTIAL_BACKUPS\AP_Arena_differential_20250119.bak'
WITH
    FILE = 1,
    NORECOVERY,
    NOUNLOAD,
    STATS = 5
GO

-- RESTORE THE TRANSACTION LOGS
RESTORE LOG [AP_Arena]
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\T_LOGS\AP_Arena_LogBackup_2025011919.trn'
WITH
    FILE = 1,
    NORECOVERY,
    NOUNLOAD,
    STATS = 5
GO

-- Restore Database
RESTORE DATABASE [AP_Arena] WITH RECOVERY;
GO

-- Check Table
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

-------------------------------------------------------------------------------------------------------------------------
-- Automating Backups
USE msdb;
GO

-- Full Backup at Every Monday 9am

-- Step 1: Create the Job
EXEC dbo.sp_add_job 
    @job_name = N'Full Backup - AP_Arena', 
    @description = N'Performs a full database backup every Monday at 10 AM',
    @enabled = 1; -- Enable the job
GO

-- Step 2: Add the Job Step
EXEC dbo.sp_add_jobstep 
    @job_name = N'Full Backup - AP_Arena', 
    @step_name = N'Full Backup Step', 
    @retry_attempts = 3, -- attempt 3 times if failed
    @retry_interval = 1, -- retry every minute
    @subsystem = N'TSQL', 
    @command = N'DECLARE @FileName AS NVARCHAR(255);
	DECLARE @FilePath AS NVARCHAR(255);
	SET @FileName = ''AP_Arena_Full_'' 
					+ CONVERT(VARCHAR(8), GETDATE(), 112) -- YYYYMMDD
					+ ''.bak''; -- Full backup with .bak extension
	SET @FilePath = ''C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\FULL_BACKUPS\'' + @FileName;
	PRINT @FilePath;
	BACKUP DATABASE [AP_Arena]
	TO DISK = @FilePath
	WITH
		FORMAT,
		INIT,
		NAME = @FileName,
		STATS = 10;',
		@database_name = N'master';
GO

-- Step 3: Create the Schedule
EXEC dbo.sp_add_schedule
    @schedule_name = N'Full Backup Schedule - Monday 10 AM',
    @freq_type = 8, -- weekly
    @freq_interval = 2, -- Monday (1=Sunday, 2=Monday, 3=Tuesday, ...)
    @freq_subday_type = 1, -- At a specific time
    @active_start_time = 100000, -- 10:00 AM (HHMMSS)
    @active_start_date = 20250111, -- Start date (YYYYMMDD)
    @active_end_date = 99991231, -- End date (indefinite)
    @freq_recurrence_factor = 1; -- Every week
GO

-- Step 4: Attach the Schedule to the Job
EXEC dbo.sp_attach_schedule
    @job_name = N'Full Backup - AP_Arena',
    @schedule_name = N'Full Backup Schedule - Monday 10 AM';
GO

-- Step 5: Add the Job to the Server
EXEC dbo.sp_add_jobserver
    @job_name = N'Full Backup - AP_Arena';
GO

--------------------------------------------------------------------
-- Differential Backup at Every Day 2pm
-- Step 1: Create the Job
EXEC dbo.sp_add_job 
    @job_name = N'Differential Backup - AP_Arena', 
    @description = N'Performs a differential database backup daily at 2 PM',
    @enabled = 1; -- Enable the job
GO

-- Step 2: Add the Job Step
EXEC dbo.sp_add_jobstep 
    @job_name = N'Differential Backup - AP_Arena', 
    @step_name = N'Differential Backup Step', 
    @retry_attempts = 3, -- attempt 3 times if failed
    @retry_interval = 1, -- retry every minute
    @subsystem = N'TSQL', 
    @command = N'DECLARE @FileName AS NVARCHAR(255);
	DECLARE @FilePath AS NVARCHAR(255);
	SET @FileName = ''AP_Arena_Differential_'' 
					+ CONVERT(VARCHAR(8), GETDATE(), 112) -- YYYYMMDD
					+ ''.bak''; -- Differential backup with .bak extension
	SET @FilePath = ''C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\DIFFERENTIAL_BACKUPS\'' + @FileName;
	PRINT @FilePath;
	BACKUP DATABASE [AP_Arena]
	TO DISK = @FilePath
	WITH
		DIFFERENTIAL,
		INIT,
		NAME = @FileName,
		STATS = 10;',
		@database_name = N'master';
GO

-- Step 3: Create the Schedule
EXEC dbo.sp_add_schedule
    @schedule_name = N'Differential Backup Schedule - Daily 2 PM',
    @freq_type = 4, -- daily
    @freq_interval = 1, -- every day
    @freq_subday_type = 1, -- At a specific time
    @active_start_time = 140000, -- 2:00 PM (HHMMSS)
    @active_start_date = 20250111, -- Start date (YYYYMMDD)
    @active_end_date = 99991231; -- End date (indefinite)
GO

-- Step 4: Attach the Schedule to the Job
EXEC dbo.sp_attach_schedule
    @job_name = N'Differential Backup - AP_Arena',
    @schedule_name = N'Differential Backup Schedule - Daily 2 PM';
GO

-- Step 5: Add the Job to the Server
EXEC dbo.sp_add_jobserver
    @job_name = N'Differential Backup - AP_Arena';
GO

--------------------------------------------------------------------
-- Transactional Backup at Every Hour
-- Step 1: Create the Job
EXEC dbo.sp_add_job 
    @job_name = N'Transactional Log Backup', 
    @description = N'Performs T-log backup regularly',
    @enabled = 1; -- Enable the job
GO

-- Step 2: Add the Job Step
EXEC dbo.sp_add_jobstep 
    @job_name = N'Transactional Log Backup', 
    @step_name = N'T-log Backup', 
    @retry_attempts = 3, -- attempt 3 times if failed
    @retry_interval = 1, -- retry every minute
    @subsystem = N'TSQL', 
    @command = N'DECLARE @FileName AS VARCHAR(100);
	DECLARE @FilePath AS VARCHAR(255);
	SET @FileName = ''AP_Arena_TLog_'' 
					+ CONVERT(VARCHAR(8), GETDATE(), 112) -- YYYYMMDD
					+ ''_'' 
					+ REPLACE(CONVERT(VARCHAR(8), GETDATE(), 108), '':'', '''') -- HHMMSS
					+ ''.trn'';
	SET @FilePath = ''C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\T_LOGS\'' + @FileName;
	PRINT @FilePath;
	BACKUP LOG [AP_Arena]
	TO DISK = @FilePath
	WITH
		NOFORMAT,
		NOINIT,
		NAME = @FileName,
		NOSKIP,
		NOREWIND,
		NOUNLOAD,
		ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [BackUpCert]),
		STATS = 5;',
		@database_name = N'master';
GO

-- Step 3: Create the Schedule
EXEC dbo.sp_add_schedule
    @schedule_name = N'T-Log Backup Schedule',
    @freq_type = 4, -- days
    @freq_interval = 1, -- daily
    @freq_subday_type = 8, -- hours
    @freq_subday_interval = 1, -- every hour
    @active_start_date = 20250111, -- start date
    @active_end_date = 99991231, -- end date (indefinite)
    @active_start_time = 0, -- start time (midnight)
    @active_end_time = 235959; -- end time (just before midnight)
GO

-- Step 4: Attach the Schedule to the Job
EXEC dbo.sp_attach_schedule
    @job_name = N'Transactional Log Backup',
    @schedule_name = N'T-Log Backup Schedule';
GO

-- Step 5: Add the Job to the Server
EXEC dbo.sp_add_jobserver
    @job_name = N'Transactional Log Backup';
GO


