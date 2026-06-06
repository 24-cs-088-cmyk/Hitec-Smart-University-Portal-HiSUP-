-- ============================================================
-- trg_AfterFeePayment.sql
-- Writes to AuditLog after every fee payment insert
-- ============================================================
CREATE OR ALTER TRIGGER trg_AfterFeePayment
ON FeePayments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AuditLog (TableName, Operation, NewValue, DBUser)
    SELECT
        'FeePayments',
        'INSERT',
        CONCAT('PaymentID:', i.PaymentID,
               ' StudentID:', i.StudentID,
               ' Amount:', i.AmountPaid,
               ' Status:', i.Status),
        SYSTEM_USER
    FROM inserted i;
END;
GO
