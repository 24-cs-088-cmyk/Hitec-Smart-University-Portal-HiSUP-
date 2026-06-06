-- ============================================================
-- RegisterStudent.sql
-- Registers a new student with transaction and error handling
-- ============================================================
CREATE OR ALTER PROCEDURE RegisterStudent
    @FirstName      NVARCHAR(50),
    @LastName       NVARCHAR(50),
    @Email          NVARCHAR(100),
    @DepartmentID   INT,
    @ProgramID      INT,
    @UserAccountID  INT = NULL,
    @NewStudentID   INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validate inputs
        IF @FirstName IS NULL OR LTRIM(RTRIM(@FirstName)) = ''
            THROW 50001, 'First name cannot be empty.', 1;
        IF @Email IS NULL OR @Email NOT LIKE '%@%.%'
            THROW 50002, 'Invalid email address.', 1;
        IF NOT EXISTS (SELECT 1 FROM Departments WHERE DepartmentID = @DepartmentID)
            THROW 50003, 'Department does not exist.', 1;
        IF NOT EXISTS (SELECT 1 FROM Programs WHERE ProgramID = @ProgramID)
            THROW 50004, 'Program does not exist.', 1;
        IF EXISTS (SELECT 1 FROM Students WHERE Email = @Email)
            THROW 50005, 'A student with this email already exists.', 1;

        BEGIN TRANSACTION;
            INSERT INTO Students (FirstName, LastName, Email, DepartmentID, ProgramID, UserAccountID)
            VALUES (@FirstName, @LastName, @Email, @DepartmentID, @ProgramID, @UserAccountID);
            SET @NewStudentID = SCOPE_IDENTITY();
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
