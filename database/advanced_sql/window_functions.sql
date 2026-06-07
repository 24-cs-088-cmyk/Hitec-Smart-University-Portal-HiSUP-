-- ============================================================
-- window_functions.sql
-- RANK, DENSE_RANK, ROW_NUMBER, NTILE, LAG, LEAD, SUM OVER
-- ============================================================
USE HiSUP_DB;
GO

-- ── 1. RANK, DENSE_RANK, ROW_NUMBER, NTILE on results ───────
SELECT
    s.StudentID,
    s.FirstName + ' ' + s.LastName     AS StudentName,
    d.DeptName,
    s.CGPA,
    RANK()        OVER (PARTITION BY s.DepartmentID ORDER BY s.CGPA DESC) AS Rank,
    DENSE_RANK()  OVER (PARTITION BY s.DepartmentID ORDER BY s.CGPA DESC) AS DenseRank,
    ROW_NUMBER()  OVER (PARTITION BY s.DepartmentID ORDER BY s.CGPA DESC) AS RowNum,
    NTILE(4)      OVER (PARTITION BY s.DepartmentID ORDER BY s.CGPA DESC) AS Quartile
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
WHERE s.IsActive = 1
ORDER BY d.DeptName, Rank;
GO

-- ── 2. LAG and LEAD: Compare fee payments over time ─────────
SELECT
    fp.PaymentID,
    s.FirstName + ' ' + s.LastName     AS StudentName,
    fp.PaymentDate,
    fp.AmountPaid,
    LAG(fp.AmountPaid)  OVER (PARTITION BY fp.StudentID ORDER BY fp.PaymentDate)
                                        AS PreviousPayment,
    LEAD(fp.AmountPaid) OVER (PARTITION BY fp.StudentID ORDER BY fp.PaymentDate)
                                        AS NextPayment,
    fp.AmountPaid -
    ISNULL(LAG(fp.AmountPaid) OVER (PARTITION BY fp.StudentID ORDER BY fp.PaymentDate), 0)
                                        AS ChangeFromPrevious
FROM FeePayments fp
JOIN Students s ON fp.StudentID = s.StudentID
ORDER BY fp.StudentID, fp.PaymentDate;
GO

-- ── 3. Running total of fee payments ────────────────────────
SELECT
    fp.PaymentDate,
    fp.StudentID,
    fp.AmountPaid,
    SUM(fp.AmountPaid) OVER (
        PARTITION BY fp.StudentID
        ORDER BY fp.PaymentDate
        ROWS UNBOUNDED PRECEDING
    )                                   AS RunningTotal,
    SUM(fp.AmountPaid) OVER ()          AS GrandTotal
FROM FeePayments fp
ORDER BY fp.StudentID, fp.PaymentDate;
GO

-- ── 4. Moving average attendance ────────────────────────────
SELECT
    ar.StudentID,
    ar.AttendanceDate,
    ar.Status,
    AVG(CAST(CASE WHEN ar.Status = 'Present' THEN 1 ELSE 0 END AS FLOAT))
        OVER (
            PARTITION BY ar.StudentID
            ORDER BY ar.AttendanceDate
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) * 100                         AS MovingAvg3Class
FROM AttendanceRecords ar
ORDER BY ar.StudentID, ar.AttendanceDate;
GO
