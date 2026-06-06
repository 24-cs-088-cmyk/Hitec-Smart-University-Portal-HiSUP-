-- ============================================================
-- vw_ResultCard.sql
-- Updatable view WITH SCHEMABINDING (2 of 2 updatable views)
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_ResultCard
WITH SCHEMABINDING
AS
SELECT
    g.GradeID,
    g.EnrollmentID,
    g.MarksObtained,
    g.LetterGrade,
    g.GradePoints,
    g.EnteredAt
FROM dbo.Grades g;
GO

CREATE OR ALTER TRIGGER trg_UpdateResultCard
ON vw_ResultCard
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Grades
    SET MarksObtained = i.MarksObtained,
        LetterGrade   = i.LetterGrade,
        GradePoints   = i.GradePoints
    FROM dbo.Grades g
    JOIN inserted i ON g.GradeID = i.GradeID;
END;
GO
