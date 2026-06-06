-- ============================================================
-- vw_ExamTimetable.sql
-- Updatable view WITH SCHEMABINDING (1 of 2 updatable views)
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER VIEW vw_ExamTimetable
WITH SCHEMABINDING
AS
SELECT
    ex.ExamID,
    ex.SectionID,
    ex.ExamDateTime,
    ex.Venue,
    ex.ExamType,
    ex.TotalMarks
FROM dbo.ExamSchedule ex;
GO

-- Make it updatable via instead-of trigger
CREATE OR ALTER TRIGGER trg_UpdateExamTimetable
ON vw_ExamTimetable
INSTEAD OF UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ExamSchedule
    SET ExamDateTime = i.ExamDateTime,
        Venue        = i.Venue,
        ExamType     = i.ExamType,
        TotalMarks   = i.TotalMarks
    FROM dbo.ExamSchedule ex
    JOIN inserted i ON ex.ExamID = i.ExamID;
END;
GO
