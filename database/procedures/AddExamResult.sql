-- ============================================================
-- AddExamResult.sql
-- Adds or updates an exam result for a student
-- ============================================================
CREATE OR ALTER PROCEDURE AddExamResult
    @StudentID      INT,
    @ExamID         INT,
    @MarksObtained  DECIMAL(5,2),
    @ResultID       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50090, 'Student not found.', 1;
        IF NOT EXISTS (SELECT 1 FROM ExamSchedule WHERE ExamID = @ExamID)
            THROW 50091, 'Exam not found.', 1;

        DECLARE @TotalMarks INT;
        SELECT @TotalMarks = TotalMarks FROM ExamSchedule WHERE ExamID = @ExamID;
        IF @MarksObtained > @TotalMarks
            THROW 50092, 'Marks obtained cannot exceed total marks.', 1;

        DECLARE @Grade NVARCHAR(2) = CASE
            WHEN @MarksObtained >= @TotalMarks * 0.85 THEN 'A'
            WHEN @MarksObtained >= @TotalMarks * 0.70 THEN 'B'
            WHEN @MarksObtained >= @TotalMarks * 0.55 THEN 'C'
            WHEN @MarksObtained >= @TotalMarks * 0.45 THEN 'D'
            ELSE 'F'
        END;

        BEGIN TRANSACTION;
            MERGE Results AS target
            USING (SELECT @StudentID AS StudentID, @ExamID AS ExamID) AS source
                ON target.StudentID = source.StudentID AND target.ExamID = source.ExamID
            WHEN MATCHED THEN
                UPDATE SET MarksObtained = @MarksObtained, Grade = @Grade
            WHEN NOT MATCHED THEN
                INSERT (StudentID, ExamID, MarksObtained, Grade)
                VALUES (@StudentID, @ExamID, @MarksObtained, @Grade);

            SELECT @ResultID = ResultID FROM Results
            WHERE StudentID = @StudentID AND ExamID = @ExamID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
