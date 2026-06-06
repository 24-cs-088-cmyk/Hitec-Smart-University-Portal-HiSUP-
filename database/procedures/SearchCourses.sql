-- ============================================================
-- SearchCourses.sql
-- Dynamic, injection-safe course search using sp_executesql
-- ============================================================
CREATE OR ALTER PROCEDURE SearchCourses
    @Keyword        NVARCHAR(100) = NULL,
    @DepartmentID   INT           = NULL,
    @CreditHours    INT           = NULL,
    @SemesterLabel  NVARCHAR(20)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @SQL    NVARCHAR(MAX);
        DECLARE @Params NVARCHAR(500);

        SET @SQL = N'
            SELECT
                c.CourseID,
                c.CourseCode,
                c.CourseName,
                c.CreditHours,
                d.DeptName,
                pre.CourseName  AS PrerequisiteCourse,
                sec.SectionID,
                sec.SemesterLabel,
                sec.SeatsAvailable,
                f.FirstName + '' '' + f.LastName AS FacultyName
            FROM Courses c
            JOIN Departments d   ON c.DepartmentID       = d.DepartmentID
            LEFT JOIN Courses pre ON c.PrerequisiteCourseID = pre.CourseID
            LEFT JOIN Sections sec ON c.CourseID          = sec.CourseID
            LEFT JOIN Faculty  f   ON sec.FacultyID       = f.FacultyID
            WHERE c.IsActive = 1';

        IF @Keyword IS NOT NULL
            SET @SQL = @SQL + N' AND (c.CourseName LIKE ''%'' + @Keyword + ''%''
                                   OR c.CourseCode LIKE ''%'' + @Keyword + ''%'')';
        IF @DepartmentID IS NOT NULL
            SET @SQL = @SQL + N' AND c.DepartmentID = @DepartmentID';
        IF @CreditHours IS NOT NULL
            SET @SQL = @SQL + N' AND c.CreditHours = @CreditHours';
        IF @SemesterLabel IS NOT NULL
            SET @SQL = @SQL + N' AND sec.SemesterLabel = @SemesterLabel';

        SET @SQL = @SQL + N' ORDER BY c.CourseCode;';

        SET @Params = N'@Keyword NVARCHAR(100), @DepartmentID INT,
                        @CreditHours INT, @SemesterLabel NVARCHAR(20)';

        EXEC sp_executesql @SQL, @Params,
            @Keyword        = @Keyword,
            @DepartmentID   = @DepartmentID,
            @CreditHours    = @CreditHours,
            @SemesterLabel  = @SemesterLabel;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
