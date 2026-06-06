-- ============================================================
-- audit_triggers.sql
-- Audit triggers for Students, FeePayments, Grades
-- ============================================================
USE HiSUP_DB;
GO

-- ── Audit: Students INSERT ──────────────────────────────────
CREATE OR ALTER TRIGGER trg_AuditStudentInsert
ON Students
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, NewValue, DBUser)
    SELECT
        'Students', 'INSERT',
        CONCAT('StudentID:', i.StudentID,
               ' Name:', i.FirstName, ' ', i.LastName,
               ' Email:', i.Email),
        SYSTEM_USER
    FROM inserted i;
END;
GO

-- ── Audit: Students DELETE ──────────────────────────────────
CREATE OR ALTER TRIGGER trg_AuditStudentDelete
ON Students
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, OldValue, DBUser)
    SELECT
        'Students', 'DELETE',
        CONCAT('StudentID:', d.StudentID,
               ' Name:', d.FirstName, ' ', d.LastName,
               ' Email:', d.Email),
        SYSTEM_USER
    FROM deleted d;
END;
GO

-- ── Audit: Grades INSERT ────────────────────────────────────
CREATE OR ALTER TRIGGER trg_AuditGradeInsert
ON Grades
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, NewValue, DBUser)
    SELECT
        'Grades', 'INSERT',
        CONCAT('GradeID:', i.GradeID,
               ' EnrollmentID:', i.EnrollmentID,
               ' Marks:', i.MarksObtained,
               ' Grade:', i.LetterGrade),
        SYSTEM_USER
    FROM inserted i;
END;
GO

-- ── Audit: Grades UPDATE ────────────────────────────────────
CREATE OR ALTER TRIGGER trg_AuditGradeUpdate
ON Grades
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, OldValue, NewValue, DBUser)
    SELECT
        'Grades', 'UPDATE',
        CONCAT('Marks:', d.MarksObtained, ' Grade:', d.LetterGrade),
        CONCAT('Marks:', i.MarksObtained, ' Grade:', i.LetterGrade),
        SYSTEM_USER
    FROM deleted  d
    JOIN inserted i ON d.GradeID = i.GradeID;
END;
GO

-- ── Audit: Grades DELETE ────────────────────────────────────
CREATE OR ALTER TRIGGER trg_AuditGradeDelete
ON Grades
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, OldValue, DBUser)
    SELECT
        'Grades', 'DELETE',
        CONCAT('GradeID:', d.GradeID,
               ' EnrollmentID:', d.EnrollmentID,
               ' Marks:', d.MarksObtained),
        SYSTEM_USER
    FROM deleted d;
END;
GO

-- ── Audit: FeePayments UPDATE ───────────────────────────────
CREATE OR ALTER TRIGGER trg_AuditFeePaymentUpdate
ON FeePayments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, OldValue, NewValue, DBUser)
    SELECT
        'FeePayments', 'UPDATE',
        CONCAT('PaymentID:', d.PaymentID, ' Amount:', d.AmountPaid, ' Status:', d.Status),
        CONCAT('PaymentID:', i.PaymentID, ' Amount:', i.AmountPaid, ' Status:', i.Status),
        SYSTEM_USER
    FROM deleted  d
    JOIN inserted i ON d.PaymentID = i.PaymentID;
END;
GO

-- ── Audit: FeePayments DELETE ───────────────────────────────
CREATE OR ALTER TRIGGER trg_AuditFeePaymentDelete
ON FeePayments
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, OldValue, DBUser)
    SELECT
        'FeePayments', 'DELETE',
        CONCAT('PaymentID:', d.PaymentID,
               ' StudentID:', d.StudentID,
               ' Amount:', d.AmountPaid),
        SYSTEM_USER
    FROM deleted d;
END;
GO
