-- ============================================================
-- transactions_savepoint.sql
-- Explicit transactions, SAVEPOINT, isolation levels
-- ============================================================
USE HiSUP_DB;
GO

-- ── 1. Explicit transaction: Course enrollment ───────────────
BEGIN TRY
    BEGIN TRANSACTION EnrollTxn;

        -- Step 1: Check seats
        IF (SELECT SeatsAvailable FROM Sections WHERE SectionID = 1) <= 0
            THROW 50300, 'No seats available.', 1;

        -- Savepoint after seat check
        SAVE TRANSACTION AfterSeatCheck;

        -- Step 2: Insert enrollment
        INSERT INTO Enrollments (StudentID, SectionID, Status)
        VALUES (1, 1, 'Active');

        -- Step 3: Update seat count
        UPDATE Sections SET SeatsAvailable = SeatsAvailable - 1
        WHERE SectionID = 1;

    COMMIT TRANSACTION EnrollTxn;
    PRINT 'Enrollment committed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        -- Partial rollback to savepoint if seat update fails
        IF XACT_STATE() = 1
            ROLLBACK TRANSACTION AfterSeatCheck;
        ELSE
            ROLLBACK TRANSACTION EnrollTxn;
    END;
    PRINT 'Enrollment rolled back: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ── 2. Isolation level: READ COMMITTED (default) ─────────────
-- Prevents dirty reads; allows non-repeatable reads
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    SELECT StudentID, CGPA FROM Students WHERE StudentID = 1;
    -- Another session can update and commit here
    SELECT StudentID, CGPA FROM Students WHERE StudentID = 1;
    -- Second read may differ — non-repeatable read possible
COMMIT;
GO

-- ── 3. Isolation level: SERIALIZABLE ────────────────────────
-- Prevents dirty reads, non-repeatable reads, AND phantom reads
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    SELECT StudentID, CGPA FROM Students WHERE DepartmentID = 1;
    -- No other session can insert/update/delete matching rows
    SELECT StudentID, CGPA FROM Students WHERE DepartmentID = 1;
    -- Both reads guaranteed identical
COMMIT;
GO

-- Reset to default
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
