-- ============================================================
-- EnrollInCourse.sql
-- Enrolls a student in a section with seat and duplicate check
-- ============================================================
CREATE OR ALTER PROCEDURE EnrollInCourse
    @StudentID      INT,
    @SectionID      INT,
    @EnrollmentID   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 50010, 'Student not found or inactive.', 1;
        IF NOT EXISTS (SELECT 1 FROM Sections WHERE SectionID = @SectionID)
            THROW 50011, 'Section does not exist.', 1;
        IF EXISTS (SELECT 1 FROM Enrollments WHERE StudentID = @StudentID AND SectionID = @SectionID)
            THROW 50012, 'Student is already enrolled in this section.', 1;
        IF (SELECT SeatsAvailable FROM Sections WHERE SectionID = @SectionID) <= 0
            THROW 50013, 'No seats available in this section.', 1;

        BEGIN TRANSACTION;
            INSERT INTO Enrollments (StudentID, SectionID, Status)
            VALUES (@StudentID, @SectionID, 'Active');
            SET @EnrollmentID = SCOPE_IDENTITY();
            -- Seat count updated by trg_AfterEnrollment trigger
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
