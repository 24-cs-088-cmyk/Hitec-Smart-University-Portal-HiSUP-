-- ============================================================
-- trg_AfterEnrollment.sql
-- Decreases SeatsAvailable after a student enrolls
-- ============================================================
CREATE OR ALTER TRIGGER trg_AfterEnrollment
ON Enrollments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Sections
    SET SeatsAvailable = SeatsAvailable - 1
    FROM Sections s
    JOIN inserted i ON s.SectionID = i.SectionID
    WHERE i.Status = 'Active';
END;
GO
