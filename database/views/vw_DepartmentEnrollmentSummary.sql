-- ============================================================
-- vw_DepartmentEnrollmentSummary.sql
-- Enrollment summary per department
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_DepartmentEnrollmentSummary
AS
SELECT
    d.DepartmentID,
    d.DeptName,
    d.DeptCode,
    COUNT(DISTINCT s.StudentID)                         AS TotalStudents,
    COUNT(DISTINCT e.EnrollmentID)                      AS ActiveEnrollments,
    CAST(AVG(s.CGPA) AS DECIMAL(3,2))                   AS AvgCGPA,
    MAX(s.CGPA)                                         AS MaxCGPA,
    COUNT(DISTINCT f.FacultyID)                         AS TotalFaculty,
    COUNT(DISTINCT c.CourseID)                          AS TotalCourses,
    SUM(COUNT(DISTINCT s.StudentID)) OVER ()            AS GrandTotalStudents
FROM Departments d
LEFT JOIN Students    s  ON d.DepartmentID = s.DepartmentID AND s.IsActive = 1
LEFT JOIN Enrollments e  ON s.StudentID    = e.StudentID    AND e.Status   = 'Active'
LEFT JOIN Faculty     f  ON d.DepartmentID = f.DepartmentID
LEFT JOIN Courses     c  ON d.DepartmentID = c.DepartmentID AND c.IsActive = 1
GROUP BY d.DepartmentID, d.DeptName, d.DeptCode;
GO
