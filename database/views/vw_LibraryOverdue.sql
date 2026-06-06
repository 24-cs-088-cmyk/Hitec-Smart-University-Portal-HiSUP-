-- ============================================================
-- vw_LibraryOverdue.sql
-- Overdue library items with fine calculation
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_LibraryOverdue
AS
SELECT
    li2.IssueID,
    s.StudentID,
    s.FirstName + ' ' + s.LastName          AS StudentName,
    s.Email,
    lib.Title,
    lib.Author,
    li2.IssueDate,
    li2.DueDate,
    DATEDIFF(DAY, li2.DueDate, GETDATE())   AS OverdueDays,
    DATEDIFF(DAY, li2.DueDate, GETDATE()) * 10.00 AS AccruedFine,
    ROW_NUMBER() OVER (ORDER BY DATEDIFF(DAY, li2.DueDate, GETDATE()) DESC) AS OverdueRank
FROM LibraryIssues li2
JOIN Students     s   ON li2.StudentID = s.StudentID
JOIN LibraryItems lib ON li2.ItemID    = lib.ItemID
WHERE li2.ReturnDate IS NULL
  AND li2.DueDate < CAST(GETDATE() AS DATE);
GO
