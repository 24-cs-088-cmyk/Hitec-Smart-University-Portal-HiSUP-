-- ============================================================
-- deadlock_simulation.sql
-- Run Session A and Session B in two separate SSMS windows
-- to produce a deadlock. SQL Server will kill one as victim.
-- ============================================================
USE HiSUP_DB;
GO

-- ════════════════════════════════════════════════════════════
-- SESSION A — Run in SSMS Window 1
-- ════════════════════════════════════════════════════════════
/*
BEGIN TRANSACTION;
    -- Lock Students row 1
    UPDATE Students SET CurrentSemester = 4 WHERE StudentID = 1;
    WAITFOR DELAY '00:00:05';  -- Wait 5 seconds
    -- Try to lock FeePayments — blocked by Session B
    UPDATE FeePayments SET Status = 'Paid' WHERE StudentID = 2;
COMMIT;
*/

-- ════════════════════════════════════════════════════════════
-- SESSION B — Run in SSMS Window 2 (while Session A is waiting)
-- ════════════════════════════════════════════════════════════
/*
BEGIN TRANSACTION;
    -- Lock FeePayments row 2
    UPDATE FeePayments SET Status = 'Paid' WHERE StudentID = 2;
    WAITFOR DELAY '00:00:05';  -- Wait 5 seconds
    -- Try to lock Students — blocked by Session A → DEADLOCK
    UPDATE Students SET CurrentSemester = 3 WHERE StudentID = 1;
COMMIT;
*/

-- ════════════════════════════════════════════════════════════
-- AFTER DEADLOCK: Check AuditLog for deadlock entry
-- (C# retry logic catches error 1205 and logs it)
-- ════════════════════════════════════════════════════════════
USE HiSUP_DB;
GO

-- Log deadlock event to AuditLog
INSERT INTO AuditLog (TableName, Operation, NewValue, DBUser)
VALUES (
    'DEADLOCK',
    'INSERT',
    'Deadlock occurred between Students and FeePayments tables. One session was chosen as deadlock victim and rolled back. Error 1205.',
    SYSTEM_USER
);
GO

-- Verify it was logged
SELECT * FROM AuditLog WHERE TableName = 'DEADLOCK';
GO