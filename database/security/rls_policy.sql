-- ============================================================
-- rls_policy.sql
-- Row-Level Security for Enrollments, Grades, FeePayments
-- ============================================================
USE HiSUP_DB;
GO

-- ── Predicate function for student rows ────────────────────
-- Maps the current DB user's username to a StudentID
CREATE OR ALTER FUNCTION dbo.fn_StudentRLSPredicate
    (@StudentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_Result
    WHERE
        -- Admins and finance see everything
        IS_MEMBER('db_admin')   = 1 OR
        IS_MEMBER('db_finance') = 1 OR
        IS_MEMBER('db_faculty') = 1 OR
        -- Students only see their own rows
        @StudentID = (
            SELECT s.StudentID
            FROM dbo.Students s
            JOIN dbo.UserAccounts ua ON s.UserAccountID = ua.UserAccountID
            WHERE ua.Username = USER_NAME()
        );
GO

-- ── Apply RLS to Enrollments ────────────────────────────────
CREATE SECURITY POLICY EnrollmentsRLSPolicy
    ADD FILTER PREDICATE dbo.fn_StudentRLSPredicate(StudentID)
    ON dbo.Enrollments
    WITH (STATE = ON);
GO

-- ── Predicate function for grades (via enrollment) ─────────
CREATE OR ALTER FUNCTION dbo.fn_GradeRLSPredicate
    (@EnrollmentID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_Result
    WHERE
        IS_MEMBER('db_admin')   = 1 OR
        IS_MEMBER('db_finance') = 1 OR
        IS_MEMBER('db_faculty') = 1 OR
        @EnrollmentID IN (
            SELECT e.EnrollmentID
            FROM dbo.Enrollments e
            JOIN dbo.Students    s  ON e.StudentID     = s.StudentID
            JOIN dbo.UserAccounts ua ON s.UserAccountID = ua.UserAccountID
            WHERE ua.Username = USER_NAME()
        );
GO

-- ── Apply RLS to Grades ─────────────────────────────────────
CREATE SECURITY POLICY GradesRLSPolicy
    ADD FILTER PREDICATE dbo.fn_GradeRLSPredicate(EnrollmentID)
    ON dbo.Grades
    WITH (STATE = ON);
GO

-- ── Apply RLS to FeePayments ────────────────────────────────
CREATE SECURITY POLICY FeePaymentsRLSPolicy
    ADD FILTER PREDICATE dbo.fn_StudentRLSPredicate(StudentID)
    ON dbo.FeePayments
    WITH (STATE = ON);
GO
