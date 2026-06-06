-- ============================================================
-- GetDepartmentEnrollment.sql
-- Returns enrollment summary by department
-- ============================================================
CREATE OR ALTER PROCEDURE GetDepartmentEnrollment
    @DepartmentID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            d.DepartmentID,
            d.DeptName,
            d.DeptCode,
            COUNT(DISTINCT s.StudentID)     AS TotalStudents,
            COUNT(DISTINCT e.EnrollmentID)  AS ActiveEnrollments,
            AVG(s.CGPA)                     AS AvgCGPA,
            MAX(s.CGPA)                     AS MaxCGPA,
            MIN(s.CGPA)                     AS MinCGPA,
            SUM(COUNT(DISTINCT s.StudentID)) OVER () AS GrandTotalStudents
        FROM Departments d
        LEFT JOIN Students    s ON d.DepartmentID = s.DepartmentID AND s.IsActive = 1
        LEFT JOIN Enrollments e ON s.StudentID    = e.StudentID    AND e.Status   = 'Active'
        WHERE (@DepartmentID IS NULL OR d.DepartmentID = @DepartmentID)
        GROUP BY d.DepartmentID, d.DeptName, d.DeptCode
        ORDER BY TotalStudents DESC;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
