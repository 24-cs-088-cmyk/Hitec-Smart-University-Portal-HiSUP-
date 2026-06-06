-- ============================================================
-- GetFacultyWorkload.sql
-- Returns teaching workload report for faculty
-- ============================================================
CREATE OR ALTER PROCEDURE GetFacultyWorkload
    @FacultyID      INT = NULL,
    @SemesterLabel  NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            f.FacultyID,
            f.FirstName + ' ' + f.LastName      AS FacultyName,
            f.Designation,
            d.DeptName,
            COUNT(sec.SectionID)                AS TotalSections,
            SUM(c.CreditHours)                  AS TotalCreditHours,
            COUNT(e.EnrollmentID)               AS TotalStudents,
            RANK() OVER (ORDER BY SUM(c.CreditHours) DESC) AS WorkloadRank
        FROM Faculty f
        JOIN Departments d  ON f.DepartmentID  = d.DepartmentID
        JOIN Sections    sec ON f.FacultyID    = sec.FacultyID
        JOIN Courses     c   ON sec.CourseID   = c.CourseID
        LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID AND e.Status = 'Active'
        WHERE (@FacultyID     IS NULL OR f.FacultyID        = @FacultyID)
          AND (@SemesterLabel IS NULL OR sec.SemesterLabel  = @SemesterLabel)
        GROUP BY f.FacultyID, f.FirstName, f.LastName, f.Designation, d.DeptName;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
