-- ============================================================
-- MarkAttendance.sql
-- Marks attendance for all students in a section (MERGE)
-- ============================================================
CREATE OR ALTER PROCEDURE MarkAttendance
    @SectionID      INT,
    @AttendanceDate DATE,
    @AttendanceXML  XML   -- <students><student id="1" status="Present"/></students>
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID)
            THROW 50050, 'Section not found.', 1;
        IF @AttendanceDate > CAST(GETDATE() AS DATE)
            THROW 50051, 'Cannot mark attendance for a future date.', 1;

        DECLARE @AttendanceTable TABLE (StudentID INT, Status NVARCHAR(10));

        INSERT INTO @AttendanceTable (StudentID, Status)
        SELECT
            x.value('@id',     'INT')           AS StudentID,
            x.value('@status', 'NVARCHAR(10)')  AS Status
        FROM @AttendanceXML.nodes('/students/student') AS T(x);

        BEGIN TRANSACTION;
            MERGE AttendanceRecords AS target
            USING @AttendanceTable AS source
                ON target.StudentID = source.StudentID
               AND target.SectionID = @SectionID
               AND target.AttendanceDate = @AttendanceDate
            WHEN MATCHED THEN
                UPDATE SET target.Status = source.Status
            WHEN NOT MATCHED THEN
                INSERT (StudentID, SectionID, AttendanceDate, Status)
                VALUES (source.StudentID, @SectionID, @AttendanceDate, source.Status);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
