-- ============================================================
-- ProcessFeePayment.sql
-- Processes a fee payment with full ACID transaction
-- ============================================================
CREATE OR ALTER PROCEDURE ProcessFeePayment
    @StudentID          INT,
    @FeeStructureID     INT,
    @AmountPaid         DECIMAL(10,2),
    @ReferenceNo        NVARCHAR(50),
    @BankAccountPlain   NVARCHAR(100) = NULL,
    @PaymentID          INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 50020, 'Student not found or inactive.', 1;
        IF NOT EXISTS (SELECT 1 FROM FeeStructure WHERE FeeStructureID = @FeeStructureID)
            THROW 50021, 'Fee structure not found.', 1;
        IF @AmountPaid <= 0
            THROW 50022, 'Payment amount must be greater than zero.', 1;
        IF EXISTS (SELECT 1 FROM FeePayments WHERE ReferenceNo = @ReferenceNo)
            THROW 50023, 'Duplicate reference number.', 1;

        DECLARE @RequiredAmount DECIMAL(10,2);
        SELECT @RequiredAmount = Amount FROM FeeStructure WHERE FeeStructureID = @FeeStructureID;

        DECLARE @Status NVARCHAR(20) = CASE
            WHEN @AmountPaid >= @RequiredAmount THEN 'Paid'
            ELSE 'Partial'
        END;

        DECLARE @EncryptedAccount VARBINARY(256) = NULL;
        IF @BankAccountPlain IS NOT NULL
            SET @EncryptedAccount = ENCRYPTBYPASSPHRASE('HiSUP_Secret_Key_2025', @BankAccountPlain);

        BEGIN TRANSACTION;
            INSERT INTO FeePayments (StudentID, FeeStructureID, AmountPaid, PaymentDate, BankAccount, Status, ReferenceNo)
            VALUES (@StudentID, @FeeStructureID, @AmountPaid, GETDATE(), @EncryptedAccount, @Status, @ReferenceNo);
            SET @PaymentID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
