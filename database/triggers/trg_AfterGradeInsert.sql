-- ============================================================
-- trg_AfterGradeInsert.sql
-- Recalculates and updates student CGPA after grade insert/update
-- ============================================================
CREATE OR ALTER TRIGGER trg_AfterGradeInsert
ON Grades
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Students
    SET CGPA = dbo.fn_CalculateCGPA(s.StudentID)
    FROM Students s
    JOIN Enrollments e  ON s.StudentID    = e.StudentID
    JOIN inserted    i  ON e.EnrollmentID = i.EnrollmentID;
END;
GO
