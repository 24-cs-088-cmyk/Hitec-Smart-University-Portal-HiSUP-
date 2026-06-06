-- ============================================================
-- fn_CalculateCGPA.sql
-- Calculates cumulative GPA for a student across all semesters
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_CalculateCGPA (@StudentID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @CGPA DECIMAL(3,2);
    SELECT @CGPA = CAST(
        SUM(g.GradePoints * c.CreditHours) / NULLIF(SUM(c.CreditHours), 0)
    AS DECIMAL(3,2))
    FROM Enrollments e
    JOIN Sections sec ON e.SectionID   = sec.SectionID
    JOIN Courses  c   ON sec.CourseID  = c.CourseID
    JOIN Grades   g   ON e.EnrollmentID = g.EnrollmentID
    WHERE e.StudentID = @StudentID AND e.Status = 'Completed';

    RETURN ISNULL(@CGPA, 0.00);
END;
GO
