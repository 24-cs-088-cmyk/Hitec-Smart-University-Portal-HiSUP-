-- ============================================================
-- column_encryption.sql
-- Encrypt CNIC and BankAccount; demonstrate decryption
-- ============================================================
USE HiSUP_DB;
GO

-- ── Encrypt existing student CNICs ─────────────────────────
-- In production this runs once during student registration
-- via the RegisterStudent procedure or a migration script

-- Example: encrypt a CNIC for student 1
UPDATE Students
SET CNIC = ENCRYPTBYPASSPHRASE('HiSUP_Secret_Key_2025', '42101-1234567-1')
WHERE StudentID = 1;

UPDATE Students
SET CNIC = ENCRYPTBYPASSPHRASE('HiSUP_Secret_Key_2025', '42201-7654321-2')
WHERE StudentID = 2;

UPDATE Students
SET CNIC = ENCRYPTBYPASSPHRASE('HiSUP_Secret_Key_2025', '42301-1122334-3')
WHERE StudentID = 3;
GO

-- ── Decrypt demonstration ───────────────────────────────────
-- Only users who know the passphrase can decrypt
SELECT
    StudentID,
    FirstName,
    LastName,
    CONVERT(NVARCHAR(20),
        DECRYPTBYPASSPHRASE('HiSUP_Secret_Key_2025', CNIC)
    ) AS DecryptedCNIC
FROM Students
WHERE CNIC IS NOT NULL;
GO

-- ── Stored procedure to decrypt CNIC safely ────────────────
CREATE OR ALTER PROCEDURE GetStudentCNIC
    @StudentID  INT,
    @Passphrase NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50200, 'Student not found.', 1;

        SELECT
            StudentID,
            FirstName + ' ' + LastName AS FullName,
            CONVERT(NVARCHAR(20),
                DECRYPTBYPASSPHRASE(@Passphrase, CNIC)
            ) AS CNIC
        FROM Students
        WHERE StudentID = @StudentID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
