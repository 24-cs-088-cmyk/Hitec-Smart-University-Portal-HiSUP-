-- ============================================================
-- pivot_unpivot.sql
-- Semester-wise attendance matrix using PIVOT and UNPIVOT
-- ============================================================
USE HiSUP_DB;
GO

-- ── PIVOT: Attendance status count per section per student ───
SELECT *
FROM (
    SELECT
        s.FirstName + ' ' + s.LastName  AS StudentName,
        sec.SemesterLabel,
        ar.Status
    FROM AttendanceRecords ar
    JOIN Students  s   ON ar.StudentID  = s.StudentID
    JOIN Sections  sec ON ar.SectionID  = sec.SectionID
) AS SourceData
PIVOT (
    COUNT(Status)
    FOR Status IN ([Present], [Absent], [Leave])
) AS PivotTable
ORDER BY StudentName, SemesterLabel;
GO

-- ── PIVOT: Fee types as columns per student ──────────────────
SELECT *
FROM (
    SELECT
        s.FirstName + ' ' + s.LastName  AS StudentName,
        fs.FeeType,
        fp.AmountPaid
    FROM FeePayments fp
    JOIN Students    s  ON fp.StudentID      = s.StudentID
    JOIN FeeStructure fs ON fp.FeeStructureID = fs.FeeStructureID
) AS FeeSource
PIVOT (
    SUM(AmountPaid)
    FOR FeeType IN ([Tuition], [Exam], [Lab], [Hostel], [Library], [Miscellaneous])
) AS FeePivot
ORDER BY StudentName;
GO

-- ── UNPIVOT: Turn fee columns back into rows ─────────────────
WITH FeePivoted AS (
    SELECT *
    FROM (
        SELECT
            s.FirstName + ' ' + s.LastName  AS StudentName,
            fs.FeeType,
            fp.AmountPaid
        FROM FeePayments fp
        JOIN Students     s  ON fp.StudentID       = s.StudentID
        JOIN FeeStructure fs ON fp.FeeStructureID  = fs.FeeStructureID
    ) AS FeeSource
    PIVOT (
        SUM(AmountPaid)
        FOR FeeType IN ([Tuition], [Exam], [Lab], [Hostel], [Library], [Miscellaneous])
    ) AS FeePivot
)
SELECT StudentName, FeeType, AmountPaid
FROM FeePivoted
UNPIVOT (
    AmountPaid FOR FeeType IN ([Tuition], [Exam], [Lab], [Hostel], [Library], [Miscellaneous])
) AS Unpivoted
WHERE AmountPaid IS NOT NULL
ORDER BY StudentName, FeeType;
GO
