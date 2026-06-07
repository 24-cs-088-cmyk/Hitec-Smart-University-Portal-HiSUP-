-- ============================================================
-- merge_grade_import.sql
-- Bulk grade import using MERGE (INSERT + UPDATE + DELETE)
-- ============================================================
USE HiSUP_DB;
GO

CREATE OR ALTER PROCEDURE BulkImportGrades
    @GradesXML XML
    -- Format: <grades><grade enrollmentId="1" marks="85.5"/></grades>
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Parse XML into temp table
        DECLARE @ImportTable TABLE (
            EnrollmentID    INT,
            MarksObtained   DECIMAL(5,2),
            LetterGrade     NVARCHAR(2),
            GradePoints     DECIMAL(3,2)
        );

        INSERT INTO @ImportTable (EnrollmentID, MarksObtained, LetterGrade, GradePoints)
        SELECT
            x.value('@enrollmentId', 'INT')         AS EnrollmentID,
            x.value('@marks',        'DECIMAL(5,2)') AS MarksObtained,
            dbo.fn_GetLetterGrade(x.value('@marks', 'DECIMAL(5,2)')) AS LetterGrade,
            CASE
                WHEN x.value('@marks', 'DECIMAL(5,2)') >= 85 THEN 4.00
                WHEN x.value('@marks', 'DECIMAL(5,2)') >= 70 THEN 3.00
                WHEN x.value('@marks', 'DECIMAL(5,2)') >= 55 THEN 2.00
                WHEN x.value('@marks', 'DECIMAL(5,2)') >= 45 THEN 1.00
                ELSE 0.00
            END AS GradePoints
        FROM @GradesXML.nodes('/grades/grade') AS T(x);

        BEGIN TRANSACTION;
            -- SAVEPOINT before merge
            SAVE TRANSACTION BeforeMerge;

            MERGE Grades AS target
            USING @ImportTable AS source
                ON target.EnrollmentID = source.EnrollmentID
            -- Update existing grade
            WHEN MATCHED THEN
                UPDATE SET
                    target.MarksObtained = source.MarksObtained,
                    target.LetterGrade   = source.LetterGrade,
                    target.GradePoints   = source.GradePoints,
                    target.EnteredAt     = GETDATE()
            -- Insert new grade
            WHEN NOT MATCHED BY TARGET THEN
                INSERT (EnrollmentID, MarksObtained, LetterGrade, GradePoints)
                VALUES (source.EnrollmentID, source.MarksObtained,
                        source.LetterGrade,  source.GradePoints)
            -- Delete grade removed from import
            WHEN NOT MATCHED BY SOURCE THEN
                DELETE;

        COMMIT TRANSACTION;

        -- Return summary
        SELECT
            SUM(CASE WHEN action = 'INSERT' THEN 1 ELSE 0 END) AS Inserted,
            SUM(CASE WHEN action = 'UPDATE' THEN 1 ELSE 0 END) AS Updated,
            SUM(CASE WHEN action = 'DELETE' THEN 1 ELSE 0 END) AS Deleted
        FROM (
            MERGE Grades AS target
            USING @ImportTable AS source
                ON target.EnrollmentID = source.EnrollmentID
            WHEN MATCHED THEN UPDATE SET target.EnteredAt = target.EnteredAt
            OUTPUT $action AS action
        ) AS MergeOutput;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION BeforeMerge;
            ROLLBACK TRANSACTION;
        END;
        THROW;
    END CATCH
END;
GO

-- ── Test MERGE ───────────────────────────────────────────────
DECLARE @TestXML XML = '
<grades>
    <grade enrollmentId="1" marks="90.0"/>
    <grade enrollmentId="2" marks="78.5"/>
    <grade enrollmentId="3" marks="65.0"/>
</grades>';

EXEC BulkImportGrades @GradesXML = @TestXML;
GO
