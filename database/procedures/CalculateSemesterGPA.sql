-- ============================================================
-- CalculateSemesterGPA.sql
-- Calculates and returns GPA for a student in a semester
-- ============================================================
CREATE OR ALTER PROCEDURE CalculateSemesterGPA
    @StudentID      INT,
    @SemesterLabel  NVARCHAR(20),
    @GPA            DECIMAL(3,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50040, 'Student not found.', 1;

        SELECT @GPA = CAST(
            SUM(g.GradePoints * c.CreditHours) / NULLIF(SUM(c.CreditHours), 0)
        AS DECIMAL(3,2))
        FROM Enrollments e
        JOIN Sections sec ON e.SectionID  = sec.SectionID
        JOIN Courses  c   ON sec.CourseID = c.CourseID
        JOIN Grades   g   ON e.EnrollmentID = g.EnrollmentID
        WHERE e.StudentID = @StudentID
          AND sec.SemesterLabel = @SemesterLabel;

        SET @GPA = ISNULL(@GPA, 0.00);
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
