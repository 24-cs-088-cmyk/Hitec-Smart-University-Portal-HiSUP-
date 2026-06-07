-- ============================================================
-- cte_queries.sql
-- Recursive CTE for prerequisite chain + regular CTEs
-- ============================================================
USE HiSUP_DB;
GO

-- ── 1. Recursive CTE: Full prerequisite chain for a course ──
WITH PrerequisiteChain AS (
    -- Anchor: start from the target course
    SELECT
        CourseID,
        CourseCode,
        CourseName,
        PrerequisiteCourseID,
        0               AS Level,
        CAST(CourseName AS NVARCHAR(MAX)) AS ChainPath
    FROM Courses
    WHERE CourseID = 6  -- CS402: Advanced Database Management

    UNION ALL

    -- Recursive: walk up the prerequisite tree
    SELECT
        c.CourseID,
        c.CourseCode,
        c.CourseName,
        c.PrerequisiteCourseID,
        pc.Level + 1,
        CAST(pc.ChainPath + ' -> ' + c.CourseName AS NVARCHAR(MAX))
    FROM Courses c
    JOIN PrerequisiteChain pc ON c.CourseID = pc.PrerequisiteCourseID
)
SELECT
    Level,
    CourseCode,
    CourseName,
    ChainPath AS FullPrerequisiteChain
FROM PrerequisiteChain
ORDER BY Level DESC;
GO

-- ── 2. Regular CTE: Top student per department ───────────────
WITH RankedStudents AS (
    SELECT
        s.StudentID,
        s.FirstName + ' ' + s.LastName     AS StudentName,
        s.CGPA,
        s.CurrentSemester,
        d.DeptName,
        DENSE_RANK() OVER (
            PARTITION BY s.DepartmentID
            ORDER BY s.CGPA DESC
        ) AS DeptRank
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    WHERE s.IsActive = 1
)
SELECT
    DeptName,
    StudentName,
    CGPA,
    CurrentSemester,
    DeptRank
FROM RankedStudents
WHERE DeptRank <= 3
ORDER BY DeptName, DeptRank;
GO

-- ── 3. Multi-step CTE: Fee collection summary ────────────────
WITH FeeCollected AS (
    SELECT
        s.DepartmentID,
        SUM(fp.AmountPaid)  AS TotalCollected
    FROM FeePayments fp
    JOIN Students s ON fp.StudentID = s.StudentID
    GROUP BY s.DepartmentID
),
FeeExpected AS (
    SELECT
        s.DepartmentID,
        SUM(fs.Amount)      AS TotalExpected
    FROM FeeStructure fs
    JOIN Students s ON fs.ProgramID = s.ProgramID
    GROUP BY s.DepartmentID
)
SELECT
    d.DeptName,
    ISNULL(fe.TotalExpected,  0)    AS TotalExpected,
    ISNULL(fc.TotalCollected, 0)    AS TotalCollected,
    ISNULL(fe.TotalExpected, 0)
        - ISNULL(fc.TotalCollected, 0) AS Outstanding
FROM Departments d
LEFT JOIN FeeExpected  fe ON d.DepartmentID = fe.DepartmentID
LEFT JOIN FeeCollected fc ON d.DepartmentID = fc.DepartmentID
ORDER BY Outstanding DESC;
GO
