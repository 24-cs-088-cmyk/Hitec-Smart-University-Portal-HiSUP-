-- ============================================================
-- ReturnLibraryBook.sql
-- Processes a library book return and calculates fine
-- ============================================================
CREATE OR ALTER PROCEDURE ReturnLibraryBook
    @IssueID    INT,
    @Fine       DECIMAL(8,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM LibraryIssues WHERE IssueID = @IssueID)
            THROW 50080, 'Issue record not found.', 1;
        IF EXISTS (SELECT 1 FROM LibraryIssues WHERE IssueID = @IssueID AND ReturnDate IS NOT NULL)
            THROW 50081, 'This book has already been returned.', 1;

        DECLARE @DueDate    DATE;
        DECLARE @ItemID     INT;
        DECLARE @OverdueDays INT;

        SELECT @DueDate = DueDate, @ItemID = ItemID
        FROM LibraryIssues WHERE IssueID = @IssueID;

        SET @OverdueDays = DATEDIFF(DAY, @DueDate, GETDATE());
        SET @Fine = CASE WHEN @OverdueDays > 0 THEN @OverdueDays * 10.00 ELSE 0 END;

        BEGIN TRANSACTION;
            UPDATE LibraryIssues
            SET ReturnDate = GETDATE(), Fine = @Fine
            WHERE IssueID = @IssueID;
            -- CopiesAvailable restored by trg_AfterLibraryReturn trigger
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
