-- ============================================================
-- trg_AuditStudentUpdate.sql
-- Logs old and new values on Students UPDATE to AuditLog
-- ============================================================
CREATE OR ALTER TRIGGER trg_AuditStudentUpdate
ON Students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, OldValue, NewValue, DBUser)
    SELECT
        'Students',
        'UPDATE',
        CONCAT('StudentID:', d.StudentID,
               ' Name:', d.FirstName, ' ', d.LastName,
               ' CGPA:', d.CGPA,
               ' IsActive:', d.IsActive),
        CONCAT('StudentID:', i.StudentID,
               ' Name:', i.FirstName, ' ', i.LastName,
               ' CGPA:', i.CGPA,
               ' IsActive:', i.IsActive),
        SYSTEM_USER
    FROM deleted  d
    JOIN inserted i ON d.StudentID = i.StudentID;
END;
GO
