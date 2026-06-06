-- ============================================================
-- vw_StudentDashboard.sql
-- Student dashboard with window functions
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_StudentDashboard
AS
SELECT
    s.StudentID,
    s.FirstName + ' ' + s.LastName         AS FullName,
    s.Email,
    d.DeptName,
    p.ProgramName,
    s.CurrentSemester,
    s.CGPA,
    RANK()       OVER (PARTITION BY s.DepartmentID ORDER BY s.CGPA DESC) AS DeptRank,
    DENSE_RANK() OVER (PARTITION BY s.DepartmentID ORDER BY s.CGPA DESC) AS DeptDenseRank,
    NTILE(4)     OVER (PARTITION BY s.DepartmentID ORDER BY s.CGPA DESC) AS CGPAQuartile,
    -- Attendance inline
    ISNULL((
        SELECT CAST(SUM(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END) * 100.0
                    / NULLIF(COUNT(*), 0) AS DECIMAL(5,2))
        FROM AttendanceRecords ar
        WHERE ar.StudentID = s.StudentID
    ), 0.00)                                AS AttendancePercent,
    -- Outstanding fee inline
    ISNULL((
        SELECT SUM(fs.Amount)
        FROM FeeStructure fs
        WHERE fs.ProgramID = s.ProgramID
    ), 0) - ISNULL((
        SELECT SUM(fp.AmountPaid)
        FROM FeePayments fp
        WHERE fp.StudentID = s.StudentID
          AND fp.Status IN ('Paid', 'Partial')
    ), 0)                                   AS OutstandingFee,
    -- Active enrollments
    (SELECT COUNT(*) FROM Enrollments e
     WHERE e.StudentID = s.StudentID
       AND e.Status = 'Active')             AS ActiveCourses,
    s.IsActive,
    s.EnrollmentDate
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Programs    p ON s.ProgramID    = p.ProgramID;
GO