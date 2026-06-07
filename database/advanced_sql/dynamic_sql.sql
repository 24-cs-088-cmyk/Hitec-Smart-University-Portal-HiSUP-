-- ============================================================
-- dynamic_sql.sql
-- Injection-safe advanced search using sp_executesql
-- ============================================================
USE HiSUP_DB;
GO

-- ── Advanced student search with optional filters ────────────
CREATE OR ALTER PROCEDURE SearchStudents
    @FirstName      NVARCHAR(50)  = NULL,
    @LastName       NVARCHAR(50)  = NULL,
    @DepartmentID   INT           = NULL,
    @ProgramID      INT           = NULL,
    @MinCGPA        DECIMAL(3,2)  = NULL,
    @Semester       INT           = NULL,
    @IsActive       BIT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @SQL    NVARCHAR(MAX);
        DECLARE @Params NVARCHAR(MAX);

        SET @SQL = N'
            SELECT
                s.StudentID,
                s.FirstName,
                s.LastName,
                s.Email,
                s.CGPA,
                s.CurrentSemester,
                d.DeptName,
                p.ProgramName,
                s.IsActive
            FROM Students s
            JOIN Departments d ON s.DepartmentID = d.DepartmentID
            JOIN Programs    p ON s.ProgramID    = p.ProgramID
            WHERE 1 = 1';

        IF @FirstName    IS NOT NULL
            SET @SQL = @SQL + N' AND s.FirstName    LIKE ''%'' + @FirstName + ''%''';
        IF @LastName     IS NOT NULL
            SET @SQL = @SQL + N' AND s.LastName     LIKE ''%'' + @LastName + ''%''';
        IF @DepartmentID IS NOT NULL
            SET @SQL = @SQL + N' AND s.DepartmentID = @DepartmentID';
        IF @ProgramID    IS NOT NULL
            SET @SQL = @SQL + N' AND s.ProgramID    = @ProgramID';
        IF @MinCGPA      IS NOT NULL
            SET @SQL = @SQL + N' AND s.CGPA         >= @MinCGPA';
        IF @Semester     IS NOT NULL
            SET @SQL = @SQL + N' AND s.CurrentSemester = @Semester';
        IF @IsActive     IS NOT NULL
            SET @SQL = @SQL + N' AND s.IsActive     = @IsActive';

        SET @SQL = @SQL + N' ORDER BY s.LastName, s.FirstName;';

        SET @Params = N'
            @FirstName    NVARCHAR(50),
            @LastName     NVARCHAR(50),
            @DepartmentID INT,
            @ProgramID    INT,
            @MinCGPA      DECIMAL(3,2),
            @Semester     INT,
            @IsActive     BIT';

        EXEC sp_executesql @SQL, @Params,
            @FirstName    = @FirstName,
            @LastName     = @LastName,
            @DepartmentID = @DepartmentID,
            @ProgramID    = @ProgramID,
            @MinCGPA      = @MinCGPA,
            @Semester     = @Semester,
            @IsActive     = @IsActive;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- ── Test the dynamic search ──────────────────────────────────
EXEC SearchStudents @DepartmentID = 1;
EXEC SearchStudents @MinCGPA = 3.00;
EXEC SearchStudents @FirstName = 'Ali';
GO
