-- ============================================================
-- indexes.sql
-- All non-clustered, filtered, and covering indexes for HiSUP_DB
-- ============================================================
USE HiSUP_DB;
GO

-- Drop existing to avoid duplicate errors
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Enrollments_StudentID')
    DROP INDEX IX_Enrollments_StudentID ON Enrollments;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Enrollments_SectionID')
    DROP INDEX IX_Enrollments_SectionID ON Enrollments;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FeePayments_Date')
    DROP INDEX IX_FeePayments_Date ON FeePayments;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LibraryIssues_ReturnDate')
    DROP INDEX IX_LibraryIssues_ReturnDate ON LibraryIssues;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Attendance_Student_Date')
    DROP INDEX IX_Attendance_Student_Date ON AttendanceRecords;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Enrollments_Active')
    DROP INDEX IX_Enrollments_Active ON Enrollments;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FeePayments_Pending')
    DROP INDEX IX_FeePayments_Pending ON FeePayments;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Students_Email')
    DROP INDEX IX_Students_Email ON Students;
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Courses_DeptID')
    DROP INDEX IX_Courses_DeptID ON Courses;
GO

-- ============================================================
-- 1. Non-clustered covering index on Enrollments.StudentID
-- ============================================================
CREATE NONCLUSTERED INDEX IX_Enrollments_StudentID
    ON Enrollments(StudentID)
    INCLUDE (SectionID, Status, EnrollmentDate);
GO

-- ============================================================
-- 2. Non-clustered covering index on Enrollments.SectionID
-- ============================================================
CREATE NONCLUSTERED INDEX IX_Enrollments_SectionID
    ON Enrollments(SectionID)
    INCLUDE (StudentID, Status);
GO

-- ============================================================
-- 3. Non-clustered covering index on FeePayments.PaymentDate
-- ============================================================
CREATE NONCLUSTERED INDEX IX_FeePayments_Date
    ON FeePayments(PaymentDate)
    INCLUDE (StudentID, AmountPaid, Status, FeeStructureID);
GO

-- ============================================================
-- 4. Non-clustered covering index on LibraryIssues.ReturnDate
-- ============================================================
CREATE NONCLUSTERED INDEX IX_LibraryIssues_ReturnDate
    ON LibraryIssues(ReturnDate)
    INCLUDE (StudentID, ItemID, DueDate, Fine);
GO

-- ============================================================
-- 5. Covering index on AttendanceRecords(StudentID, Date)
-- ============================================================
CREATE NONCLUSTERED INDEX IX_Attendance_Student_Date
    ON AttendanceRecords(StudentID, AttendanceDate)
    INCLUDE (SectionID, Status);
GO

-- ============================================================
-- 6. FILTERED index — Active enrollments only
-- ============================================================
CREATE NONCLUSTERED INDEX IX_Enrollments_Active
    ON Enrollments(StudentID, SectionID)
    WHERE Status = 'Active';
GO

-- ============================================================
-- 7. FILTERED covering index — Pending/Overdue fee payments
-- ============================================================
CREATE NONCLUSTERED INDEX IX_FeePayments_Pending
    ON FeePayments(Status, StudentID)
    INCLUDE (AmountPaid, PaymentDate, FeeStructureID)
    WHERE Status IN ('Pending', 'Overdue');
GO

-- ============================================================
-- 8. Non-clustered index on Students.Email
-- ============================================================
CREATE NONCLUSTERED INDEX IX_Students_Email
    ON Students(Email)
    INCLUDE (StudentID, FirstName, LastName, IsActive);
GO

-- ============================================================
-- 9. Non-clustered index on Courses.DepartmentID
-- ============================================================
CREATE NONCLUSTERED INDEX IX_Courses_DeptID
    ON Courses(DepartmentID)
    INCLUDE (CourseCode, CourseName, CreditHours, IsActive);
GO

-- Verify
SELECT
    t.name      AS TableName,
    i.name      AS IndexName,
    i.type_desc AS IndexType,
    i.filter_definition AS FilterCondition
FROM sys.indexes i
JOIN sys.tables  t ON i.object_id = t.object_id
WHERE i.type > 0
  AND t.name IN ('Enrollments','FeePayments','LibraryIssues',
                 'AttendanceRecords','Students','Courses')
ORDER BY t.name, i.name;
GO

PRINT 'All 9 indexes created successfully.';
GO
