-- ============================================================
-- trg_PreventDuplicateEnrollment.sql
-- INSTEAD OF trigger — blocks duplicate enrollment attempts
-- ============================================================
CREATE OR ALTER TRIGGER trg_PreventDuplicateEnrollment
ON Enrollments
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    -- Check for duplicates
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Enrollments e ON e.StudentID = i.StudentID
                          AND e.SectionID = i.SectionID
    )
    BEGIN
        RAISERROR('Duplicate enrollment: student is already enrolled in this section.', 16, 1);
        RETURN;
    END;

    -- Check seat availability
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN Sections s ON s.SectionID = i.SectionID
        WHERE s.SeatsAvailable <= 0
    )
    BEGIN
        RAISERROR('Enrollment failed: no seats available in this section.', 16, 1);
        RETURN;
    END;

    -- Safe to insert
    INSERT INTO Enrollments (StudentID, SectionID, EnrollmentDate, Status)
    SELECT StudentID, SectionID, EnrollmentDate, Status FROM inserted;
END;
GO
