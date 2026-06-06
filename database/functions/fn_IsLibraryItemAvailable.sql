-- ============================================================
-- fn_IsLibraryItemAvailable.sql
-- Returns 1 if library item has copies available, else 0
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_IsLibraryItemAvailable (@ItemID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Available BIT = 0;
    IF EXISTS (
        SELECT 1 FROM LibraryItems
        WHERE ItemID = @ItemID AND CopiesAvailable > 0
    )
        SET @Available = 1;
    RETURN @Available;
END;
GO
