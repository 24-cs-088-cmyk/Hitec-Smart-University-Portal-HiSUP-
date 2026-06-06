-- ============================================================
-- GenerateFeeSlip.sql
-- Generates a fee slip for a student
-- ============================================================
CREATE OR ALTER PROCEDURE GenerateFeeSlip
    @StudentID      INT,
    @AcademicYear   NVARCHAR(10),
    @Semester       NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID)
            THROW 50110, 'Student not found.', 1;

        -- Student details
        SELECT
            s.StudentID,
            s.FirstName + ' ' + s.LastName  AS StudentName,
            s.Email,
            d.DeptName,
            p.ProgramName,
            s.CurrentSemester
        FROM Students s
        JOIN Departments d ON s.DepartmentID = d.DepartmentID
        JOIN Programs    p ON s.ProgramID    = p.ProgramID
        WHERE s.StudentID = @StudentID;

        -- Fee breakdown with running total
        SELECT
            fs.FeeType,
            fs.Amount,
            SUM(fs.Amount) OVER (ORDER BY fs.FeeType ROWS UNBOUNDED PRECEDING) AS RunningTotal,
            ISNULL(fp.AmountPaid, 0)    AS Paid,
            ISNULL(fp.Status, 'Pending') AS PaymentStatus
        FROM FeeStructure fs
        JOIN Students s ON s.ProgramID = fs.ProgramID
        LEFT JOIN FeePayments fp ON fp.StudentID = @StudentID
                                AND fp.FeeStructureID = fs.FeeStructureID
        WHERE s.StudentID = @StudentID
          AND fs.AcademicYear = @AcademicYear
          AND (@Semester IS NULL OR fs.Semester = @Semester)
        ORDER BY fs.FeeType;

        -- Outstanding amount
        SELECT dbo.fn_GetOutstandingFee(@StudentID) AS OutstandingFee;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
