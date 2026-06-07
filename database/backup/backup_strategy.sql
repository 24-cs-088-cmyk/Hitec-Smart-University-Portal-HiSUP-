-- ============================================================
-- backup_strategy.sql
-- Full and differential backup jobs for HiSUP_DB
-- ============================================================
USE master;
GO

-- ── Full Backup ──────────────────────────────────────────────
BACKUP DATABASE HiSUP_DB
TO DISK = 'C:\Backups\HiSUP_DB_Full.bak'
WITH
    FORMAT,
    MEDIANAME = 'HiSUP_Backup',
    NAME = 'HiSUP_DB Full Backup',
    COMPRESSION,
    STATS = 10;
GO

-- ── Differential Backup ──────────────────────────────────────
BACKUP DATABASE HiSUP_DB
TO DISK = 'C:\Backups\HiSUP_DB_Diff.bak'
WITH
    DIFFERENTIAL,
    NAME = 'HiSUP_DB Differential Backup',
    COMPRESSION,
    STATS = 10;
GO

-- ── Restore from Full Backup ─────────────────────────────────
-- Run this on a fresh SQL Server instance to restore
/*
RESTORE DATABASE HiSUP_DB
FROM DISK = 'C:\Backups\HiSUP_DB_Full.bak'
WITH
    MOVE 'HiSUP_DB'     TO 'C:\Program Files\Microsoft SQL Server\MSSQL\DATA\HiSUP_DB.mdf',
    MOVE 'HiSUP_DB_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL\DATA\HiSUP_DB_log.ldf',
    REPLACE,
    STATS = 10;
GO
*/

-- ── Verify backup integrity ──────────────────────────────────
RESTORE VERIFYONLY
FROM DISK = 'C:\Backups\HiSUP_DB_Full.bak';
GO
