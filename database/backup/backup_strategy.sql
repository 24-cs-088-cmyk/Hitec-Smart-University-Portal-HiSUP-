USE master;
GO

-- Full Backup
BACKUP DATABASE HiSUP_DB
TO DISK = 'C:\HiSUP_Backup\HiSUP_DB_Full.bak'
WITH
    FORMAT,
    MEDIANAME = 'HiSUP_Backup',
    NAME = 'HiSUP_DB Full Backup',
    COMPRESSION,
    STATS = 10;
GO

-- Differential Backup
BACKUP DATABASE HiSUP_DB
TO DISK = 'C:\HiSUP_Backup\HiSUP_DB_Diff.bak'
WITH
    DIFFERENTIAL,
    NAME = 'HiSUP_DB Differential Backup',
    COMPRESSION,
    STATS = 10;
GO

-- Verify
RESTORE VERIFYONLY
FROM DISK = 'C:\HiSUP_Backup\HiSUP_DB_Full.bak';
GO