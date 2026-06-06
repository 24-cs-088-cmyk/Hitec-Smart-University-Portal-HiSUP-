-- ============================================================
-- vw_FacultyCourseLoad.sql
-- Faculty teaching load with window functions
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_FacultyCourseLoad
AS
SELECT
    f.FacultyID,
    f.FirstName + ' ' + f.LastName          AS FacultyName,
    f.Designation,
    d.DeptName,
    sec.SectionID,
    sec.SemesterLabel,
    c.CourseCode,
    c.CourseName,
    c.CreditHours,
    COUNT(e.EnrollmentID)                   AS EnrolledStudents,
    SUM(c.CreditHours) OVER
        (PARTITION BY f.FacultyID, sec.SemesterLabel) AS TotalCreditHours,
    RANK() OVER
        (PARTITION BY sec.SemesterLabel ORDER BY COUNT(e.EnrollmentID) DESC) AS SectionRank
FROM Faculty f
JOIN Departments d   ON f.DepartmentID  = d.DepartmentID
JOIN Sections    sec ON f.FacultyID     = sec.FacultyID
JOIN Courses     c   ON sec.CourseID    = c.CourseID
LEFT JOIN Enrollments e ON sec.SectionID = e.SectionID AND e.Status = 'Active'
GROUP BY f.FacultyID, f.FirstName, f.LastName, f.Designation,
         d.DeptName, sec.SectionID, sec.SemesterLabel,
         c.CourseCode, c.CourseName, c.CreditHours;
GO
