-- ============================================================
-- roles_and_permissions.sql
-- Database roles, GRANT/DENY/REVOKE for HiSUP_DB
-- ============================================================
USE HiSUP_DB;
GO

-- Create roles
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'db_student')
    CREATE ROLE db_student;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'db_faculty')
    CREATE ROLE db_faculty;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'db_admin')
    CREATE ROLE db_admin;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'db_finance')
    CREATE ROLE db_finance;
GO

-- Grant execute on all procedures to db_admin (full access)
GRANT EXECUTE ON SCHEMA::dbo TO db_admin;
GRANT SELECT  ON SCHEMA::dbo TO db_admin;
GO

-- db_student: only specific procedures
GRANT EXECUTE ON dbo.EnrollInCourse       TO db_student;
GRANT EXECUTE ON dbo.GenerateTranscript   TO db_student;
GRANT EXECUTE ON dbo.CalculateSemesterGPA TO db_student;
GRANT EXECUTE ON dbo.GetStudentReport     TO db_student;
GRANT EXECUTE ON dbo.GenerateFeeSlip      TO db_student;
GRANT EXECUTE ON dbo.IssueLibraryBook     TO db_student;
GRANT EXECUTE ON dbo.ReturnLibraryBook    TO db_student;
GRANT EXECUTE ON dbo.SearchCourses        TO db_student;
GRANT SELECT  ON dbo.vw_StudentDashboard  TO db_student;
GRANT SELECT  ON dbo.vw_ExamTimetable     TO db_student;
DENY  SELECT  ON dbo.Grades               TO db_student;
DENY  SELECT  ON dbo.FeePayments          TO db_student;
DENY  SELECT  ON dbo.Enrollments          TO db_student;
GO

-- db_faculty: teaching-related procedures
GRANT EXECUTE ON dbo.MarkAttendance       TO db_faculty;
GRANT EXECUTE ON dbo.AddExamResult        TO db_faculty;
GRANT EXECUTE ON dbo.GetFacultyWorkload   TO db_faculty;
GRANT EXECUTE ON dbo.GetStudentReport     TO db_faculty;
GRANT EXECUTE ON dbo.SearchCourses        TO db_faculty;
GRANT SELECT  ON dbo.vw_FacultyCourseLoad TO db_faculty;
GRANT SELECT  ON dbo.vw_AttendanceShortfall TO db_faculty;
GRANT SELECT  ON dbo.vw_ResultCard        TO db_faculty;
DENY  SELECT  ON dbo.FeePayments          TO db_faculty;
GO

-- db_finance: fee-related procedures
GRANT EXECUTE ON dbo.ProcessFeePayment    TO db_finance;
GRANT EXECUTE ON dbo.GenerateFeeSlip      TO db_finance;
GRANT EXECUTE ON dbo.RegisterStudent      TO db_finance;
GRANT SELECT  ON dbo.vw_FeeDefaulters     TO db_finance;
DENY  SELECT  ON dbo.Grades               TO db_finance;
GO
