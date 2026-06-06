-- ============================================================
-- GetStudentReport.sql
-- Returns full student report with window functions
-- ============================================================
CREATE OR ALTER PROCEDURE GetStudentReport
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50100, 'Student not found.', 1;

        -- Rank student within their department
        WITH DeptRank AS (
            SELECT
                StudentID,
                CGPA,
                RANK()       OVER (PARTITION BY DepartmentID ORDER BY CGPA DESC) AS DeptRank,
                DENSE_RANK() OVER (PARTITION BY DepartmentID ORDER BY CGPA DESC) AS DeptDenseRank,
                NTILE(4)     OVER (PARTITION BY DepartmentID ORDER BY CGPA DESC) AS Quartile
            FROM Students
            WHERE IsActive = 1
        )
        SELECT
            s.StudentID,
            s.FirstName + ' ' + s.LastName AS FullName,
            s.Email,
            d.DeptName,
            p.ProgramName,
            s.CurrentSemester,
            s.CGPA,
            dr.DeptRank,
            dr.DeptDenseRank,
            dr.Quartile,
            dbo.fn_GetAttendancePercentage(s.StudentID, NULL) AS OverallAttendance,
            dbo.fn_GetOutstandingFee(s.StudentID)             AS OutstandingFee
        FROM Students s
        JOIN Departments d ON s.DepartmentID = d.DepartmentID
        JOIN Programs    p ON s.ProgramID    = p.ProgramID
        JOIN DeptRank   dr ON s.StudentID    = dr.StudentID
        WHERE s.StudentID = @StudentID;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
