-- ============================================================
-- IssueLibraryBook.sql
-- Issues a library book to a student
-- ============================================================
CREATE OR ALTER PROCEDURE IssueLibraryBook
    @StudentID  INT,
    @ItemID     INT,
    @DueDays    INT = 14,
    @IssueID    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 50070, 'Student not found or inactive.', 1;
        IF NOT EXISTS (SELECT 1 FROM LibraryItems WHERE ItemID = @ItemID)
            THROW 50071, 'Library item not found.', 1;
        IF (SELECT CopiesAvailable FROM LibraryItems WHERE ItemID = @ItemID) <= 0
            THROW 50072, 'No copies available for this item.', 1;
        IF (SELECT COUNT(*) FROM LibraryIssues
            WHERE StudentID = @StudentID AND ReturnDate IS NULL) >= 3
            THROW 50073, 'Student has reached the maximum borrowing limit of 3 books.', 1;

        BEGIN TRANSACTION;
            INSERT INTO LibraryIssues (StudentID, ItemID, IssueDate, DueDate)
            VALUES (@StudentID, @ItemID, GETDATE(), DATEADD(DAY, @DueDays, GETDATE()));
            SET @IssueID = SCOPE_IDENTITY();

            UPDATE LibraryItems
            SET CopiesAvailable = CopiesAvailable - 1
            WHERE ItemID = @ItemID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
