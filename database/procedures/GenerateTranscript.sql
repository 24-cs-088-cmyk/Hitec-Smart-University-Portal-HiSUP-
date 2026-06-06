-- ============================================================
-- GenerateTranscript.sql
-- Returns full academic transcript for a student using CTE
-- ============================================================
CREATE OR ALTER PROCEDURE GenerateTranscript
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50030, 'Student not found.', 1;

        -- Student info
        SELECT
            s.StudentID,
            s.FirstName + ' ' + s.LastName   AS FullName,
            s.Email,
            d.DeptName                        AS Department,
            p.ProgramName,
            s.CurrentSemester,
            s.CGPA,
            s.EnrollmentDate
        FROM Students s
        JOIN Departments d ON s.DepartmentID = d.DepartmentID
        JOIN Programs    p ON s.ProgramID    = p.ProgramID
        WHERE s.StudentID = @StudentID;

        -- Course-wise grades using CTE
        WITH TranscriptCTE AS (
            SELECT
                c.CourseCode,
                c.CourseName,
                c.CreditHours,
                sec.SemesterLabel,
                g.MarksObtained,
                g.LetterGrade,
                g.GradePoints,
                ROW_NUMBER() OVER (PARTITION BY sec.SemesterLabel ORDER BY c.CourseCode) AS RowNum
            FROM Enrollments e
            JOIN Sections sec ON e.SectionID  = sec.SectionID
            JOIN Courses  c   ON sec.CourseID = c.CourseID
            LEFT JOIN Grades g ON e.EnrollmentID = g.EnrollmentID
            WHERE e.StudentID = @StudentID AND e.Status = 'Completed'
        )
        SELECT CourseCode, CourseName, CreditHours, SemesterLabel,
               MarksObtained, LetterGrade, GradePoints
        FROM TranscriptCTE
        ORDER BY SemesterLabel, CourseCode;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
