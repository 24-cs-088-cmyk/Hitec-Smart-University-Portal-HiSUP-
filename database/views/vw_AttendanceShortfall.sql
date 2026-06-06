-- ============================================================
-- vw_AttendanceShortfall.sql
-- Students below 75% attendance threshold
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_AttendanceShortfall
AS
SELECT
    s.StudentID,
    s.FirstName + ' ' + s.LastName          AS StudentName,
    d.DeptName,
    sec.SectionID,
    c.CourseName,
    sec.SemesterLabel,
    COUNT(ar.AttendanceID)                  AS TotalClasses,
    SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) AS Present,
    CAST(
        SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(ar.AttendanceID), 0)
    AS DECIMAL(5,2))                        AS AttendancePercent,
    75.00                                   AS MinRequired,
    LAG(CAST(
        SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) * 100.0
        / NULLIF(COUNT(ar.AttendanceID), 0)
    AS DECIMAL(5,2))) OVER
        (PARTITION BY s.StudentID ORDER BY sec.SemesterLabel) AS PrevSemesterAttendance
FROM Students s
JOIN Departments  d   ON s.DepartmentID  = d.DepartmentID
JOIN Enrollments  e   ON s.StudentID     = e.StudentID
JOIN Sections     sec ON e.SectionID     = sec.SectionID
JOIN Courses      c   ON sec.CourseID    = c.CourseID
JOIN AttendanceRecords ar ON ar.StudentID = s.StudentID
                          AND ar.SectionID = sec.SectionID
WHERE s.IsActive = 1
GROUP BY s.StudentID, s.FirstName, s.LastName, d.DeptName,
         sec.SectionID, c.CourseName, sec.SemesterLabel
HAVING CAST(
    SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) * 100.0
    / NULLIF(COUNT(ar.AttendanceID), 0)
AS DECIMAL(5,2)) < 75.00;
GO
