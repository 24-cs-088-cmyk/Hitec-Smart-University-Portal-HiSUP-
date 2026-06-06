-- ============================================================
-- fn_GetAttendancePercentage.sql
-- Returns attendance percentage for a student in a section
-- Pass NULL for @SectionID to get overall attendance
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_GetAttendancePercentage
(
    @StudentID  INT,
    @SectionID  INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total   INT;
    DECLARE @Present INT;

    SELECT @Total = COUNT(*), @Present = SUM(CASE WHEN Status = 'Present' THEN 1 ELSE 0 END)
    FROM AttendanceRecords
    WHERE StudentID = @StudentID
      AND (@SectionID IS NULL OR SectionID = @SectionID);

    RETURN CASE WHEN @Total > 0
                THEN CAST(@Present * 100.0 / @Total AS DECIMAL(5,2))
                ELSE 0.00 END;
END;
GO
