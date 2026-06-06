-- ============================================================
-- fn_GetOutstandingFee.sql
-- Returns total outstanding fee for a student
-- ============================================================
CREATE OR ALTER FUNCTION dbo.fn_GetOutstandingFee (@StudentID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalDue  DECIMAL(10,2);
    DECLARE @TotalPaid DECIMAL(10,2);
    DECLARE @ProgramID INT;

    SELECT @ProgramID = ProgramID FROM Students WHERE StudentID = @StudentID;

    SELECT @TotalDue = ISNULL(SUM(Amount), 0)
    FROM FeeStructure
    WHERE ProgramID = @ProgramID;

    SELECT @TotalPaid = ISNULL(SUM(AmountPaid), 0)
    FROM FeePayments
    WHERE StudentID = @StudentID AND Status IN ('Paid', 'Partial');

    RETURN CASE WHEN (@TotalDue - @TotalPaid) > 0
                THEN (@TotalDue - @TotalPaid)
                ELSE 0 END;
END;
GO
