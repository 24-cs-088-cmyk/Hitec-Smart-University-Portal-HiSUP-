-- ============================================================
-- vw_FeeDefaulters.sql
-- Students with outstanding or overdue fees
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_FeeDefaulters
AS
WITH FeeSummary AS (
    SELECT
        s.StudentID,
        s.FirstName + ' ' + s.LastName      AS StudentName,
        s.Email,
        d.DeptName,
        p.ProgramName,
        s.CurrentSemester,
        ISNULL(SUM(fs.Amount), 0)           AS TotalDue,
        ISNULL(SUM(fp.AmountPaid), 0)       AS TotalPaid
    FROM Students s
    JOIN Departments d  ON s.DepartmentID   = d.DepartmentID
    JOIN Programs    p  ON s.ProgramID      = p.ProgramID
    JOIN FeeStructure fs ON fs.ProgramID    = s.ProgramID
    LEFT JOIN FeePayments fp ON fp.StudentID = s.StudentID
                             AND fp.FeeStructureID = fs.FeeStructureID
    WHERE s.IsActive = 1
    GROUP BY s.StudentID, s.FirstName, s.LastName, s.Email,
             d.DeptName, p.ProgramName, s.CurrentSemester
)
SELECT
    StudentID,
    StudentName,
    Email,
    DeptName,
    ProgramName,
    CurrentSemester,
    TotalDue,
    TotalPaid,
    TotalDue - TotalPaid                    AS OutstandingAmount,
    RANK() OVER (ORDER BY (TotalDue - TotalPaid) DESC) AS DefaulterRank
FROM FeeSummary
WHERE TotalDue - TotalPaid > 0;
GO
