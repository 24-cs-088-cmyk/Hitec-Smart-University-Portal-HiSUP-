-- ============================================================
-- trg_AfterLibraryReturn.sql
-- Restores CopiesAvailable when a book is returned
-- ============================================================
CREATE OR ALTER TRIGGER trg_AfterLibraryReturn
ON LibraryIssues
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Only fire when ReturnDate changes from NULL to a date
    IF UPDATE(ReturnDate)
    BEGIN
        UPDATE LibraryItems
        SET CopiesAvailable = CopiesAvailable + 1
        FROM LibraryItems li
        JOIN inserted i  ON li.ItemID = i.ItemID
        JOIN deleted  d  ON li.ItemID = d.ItemID
        WHERE i.ReturnDate IS NOT NULL
          AND d.ReturnDate IS NULL;
    END;
END;
GO
