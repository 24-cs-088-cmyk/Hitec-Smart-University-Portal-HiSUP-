-- ============================================================
-- HiSUP_DB_Script.sql (FIXED)
-- HITEC Smart University Portal
-- CS-318 Advanced Database Management Systems
-- ============================================================

-- USE master;
-- GO
-- DROP DATABASE IF EXISTS HiSUP_DB;
-- GO
-- CREATE DATABASE HiSUP_DB;
-- GO
-- USE HiSUP_DB;
-- GO

-- ============================================================
-- 1. UserAccounts
-- ============================================================
CREATE TABLE UserAccounts (
    UserAccountID   INT             PRIMARY KEY IDENTITY(1,1),
    Username        NVARCHAR(100)   NOT NULL UNIQUE,
    PasswordHash    NVARCHAR(256)   NOT NULL,
    Role            NVARCHAR(20)    NOT NULL CHECK (Role IN ('Admin','Student','Faculty','Finance','Staff')),
    IsActive        BIT             NOT NULL DEFAULT 1,
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 2. Departments
-- ============================================================
CREATE TABLE Departments (
    DepartmentID    INT             PRIMARY KEY IDENTITY(1,1),
    DeptName        NVARCHAR(100)   NOT NULL UNIQUE,
    DeptCode        NVARCHAR(10)    NOT NULL UNIQUE,
    EstablishedYear INT             CHECK (EstablishedYear >= 1990),
    CreatedAt       DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- 3. Programs
-- ============================================================
CREATE TABLE Programs (
    ProgramID       INT             PRIMARY KEY IDENTITY(1,1),
    DepartmentID    INT             NOT NULL,
    ProgramName     NVARCHAR(100)   NOT NULL,
    Degree          NVARCHAR(20)    NOT NULL CHECK (Degree IN ('BS','MS','PhD','Associate')),
    DurationYears   INT             NOT NULL DEFAULT 4 CHECK (DurationYears BETWEEN 1 AND 6),
    CONSTRAINT FK_Programs_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- ============================================================
-- 4. Faculty
-- ============================================================
CREATE TABLE Faculty (
    FacultyID       INT             PRIMARY KEY IDENTITY(1,1),
    DepartmentID    INT             NOT NULL,
    UserAccountID   INT             NULL UNIQUE,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    Email           NVARCHAR(100)   NOT NULL UNIQUE,
    Designation     NVARCHAR(50)    NOT NULL DEFAULT 'Lecturer',
    JoiningDate     DATE            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Faculty_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Faculty_UserAccounts FOREIGN KEY (UserAccountID)
        REFERENCES UserAccounts(UserAccountID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- ============================================================
-- 5. Staff
-- ============================================================
CREATE TABLE Staff (
    StaffID         INT             PRIMARY KEY IDENTITY(1,1),
    DepartmentID    INT             NOT NULL,
    UserAccountID   INT             NULL UNIQUE,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    Email           NVARCHAR(100)   NOT NULL UNIQUE,
    Position        NVARCHAR(50)    NOT NULL,
    JoiningDate     DATE            NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Staff_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Staff_UserAccounts FOREIGN KEY (UserAccountID)
        REFERENCES UserAccounts(UserAccountID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- ============================================================
-- 6. Students
-- ============================================================
CREATE TABLE Students (
    StudentID       INT             PRIMARY KEY IDENTITY(1,1),
    DepartmentID    INT             NOT NULL,
    ProgramID       INT             NOT NULL,
    UserAccountID   INT             NULL UNIQUE,
    FirstName       NVARCHAR(50)    NOT NULL,
    LastName        NVARCHAR(50)    NOT NULL,
    Email           NVARCHAR(100)   NOT NULL UNIQUE,
    CNIC            VARBINARY(256)  NULL,
    EnrollmentDate  DATE            NOT NULL DEFAULT GETDATE(),
    CurrentSemester INT             NOT NULL DEFAULT 1 CHECK (CurrentSemester BETWEEN 1 AND 8),
    CGPA            DECIMAL(3,2)    NOT NULL DEFAULT 0.00 CHECK (CGPA BETWEEN 0 AND 4),
    IsActive        BIT             NOT NULL DEFAULT 1,
    CONSTRAINT FK_Students_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Students_Programs FOREIGN KEY (ProgramID)
        REFERENCES Programs(ProgramID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT FK_Students_UserAccounts FOREIGN KEY (UserAccountID)
        REFERENCES UserAccounts(UserAccountID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
GO

-- ============================================================
-- 7. Courses
-- ============================================================
CREATE TABLE Courses (
    CourseID                INT             PRIMARY KEY IDENTITY(1,1),
    DepartmentID            INT             NOT NULL,
    PrerequisiteCourseID    INT             NULL,
    CourseCode              NVARCHAR(10)    NOT NULL UNIQUE,
    CourseName              NVARCHAR(100)   NOT NULL,
    CreditHours             INT             NOT NULL DEFAULT 3 CHECK (CreditHours BETWEEN 1 AND 4),
    IsActive                BIT             NOT NULL DEFAULT 1,
    CONSTRAINT FK_Courses_Departments FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Courses_Prerequisite FOREIGN KEY (PrerequisiteCourseID)
        REFERENCES Courses(CourseID)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

-- ============================================================
-- 8. Sections
-- ============================================================
CREATE TABLE Sections (
    SectionID       INT             PRIMARY KEY IDENTITY(1,1),
    CourseID        INT             NOT NULL,
    FacultyID       INT             NOT NULL,
    SemesterLabel   NVARCHAR(20)    NOT NULL,
    SeatsTotal      INT             NOT NULL CHECK (SeatsTotal > 0),
    SeatsAvailable  INT             NOT NULL CHECK (SeatsAvailable >= 0),
    Room            NVARCHAR(20)    NULL,
    Schedule        NVARCHAR(100)   NULL,
    CONSTRAINT FK_Sections_Courses FOREIGN KEY (CourseID)
        REFERENCES Courses(CourseID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Sections_Faculty FOREIGN KEY (FacultyID)
        REFERENCES Faculty(FacultyID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT CHK_Seats CHECK (SeatsAvailable <= SeatsTotal)
);
GO

-- ============================================================
-- 9. Enrollments
-- NOTE: NO CASCADE on SectionID to avoid multiple cascade paths
-- ============================================================
CREATE TABLE Enrollments (
    EnrollmentID    INT             PRIMARY KEY IDENTITY(1,1),
    StudentID       INT             NOT NULL,
    SectionID       INT             NOT NULL,
    EnrollmentDate  DATE            NOT NULL DEFAULT GETDATE(),
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Active'
                    CHECK (Status IN ('Active','Dropped','Completed')),
    CONSTRAINT FK_Enrollments_Students FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Enrollments_Sections FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT UQ_Enrollment UNIQUE (StudentID, SectionID)
);
GO

-- ============================================================
-- 10. Grades
-- ============================================================
CREATE TABLE Grades (
    GradeID         INT             PRIMARY KEY IDENTITY(1,1),
    EnrollmentID    INT             NOT NULL UNIQUE,
    MarksObtained   DECIMAL(5,2)    NOT NULL CHECK (MarksObtained BETWEEN 0 AND 100),
    LetterGrade     NVARCHAR(2)     NULL,
    GradePoints     DECIMAL(3,2)    NULL CHECK (GradePoints BETWEEN 0 AND 4),
    EnteredAt       DATETIME        NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Grades_Enrollments FOREIGN KEY (EnrollmentID)
        REFERENCES Enrollments(EnrollmentID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
GO

-- ============================================================
-- 11. AttendanceRecords
-- NOTE: NO CASCADE on SectionID to avoid multiple cascade paths
-- ============================================================
CREATE TABLE AttendanceRecords (
    AttendanceID    INT             PRIMARY KEY IDENTITY(1,1),
    StudentID       INT             NOT NULL,
    SectionID       INT             NOT NULL,
    AttendanceDate  DATE            NOT NULL,
    Status          NVARCHAR(10)    NOT NULL DEFAULT 'Present'
                    CHECK (Status IN ('Present','Absent','Leave')),
    CONSTRAINT FK_Attendance_Students FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Attendance_Sections FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT UQ_Attendance UNIQUE (StudentID, SectionID, AttendanceDate)
);
GO

-- ============================================================
-- 12. ExamSchedule
-- ============================================================
CREATE TABLE ExamSchedule (
    ExamID          INT             PRIMARY KEY IDENTITY(1,1),
    SectionID       INT             NOT NULL,
    ExamDateTime    DATETIME        NOT NULL,
    Venue           NVARCHAR(50)    NOT NULL,
    ExamType        NVARCHAR(20)    NOT NULL
                    CHECK (ExamType IN ('Midterm','Final','Quiz','Assignment')),
    TotalMarks      INT             NOT NULL DEFAULT 100,
    CONSTRAINT FK_ExamSchedule_Sections FOREIGN KEY (SectionID)
        REFERENCES Sections(SectionID)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

-- ============================================================
-- 13. Results
-- NOTE: NO CASCADE on ExamID to avoid multiple cascade paths
-- ============================================================
CREATE TABLE Results (
    ResultID        INT             PRIMARY KEY IDENTITY(1,1),
    StudentID       INT             NOT NULL,
    ExamID          INT             NOT NULL,
    MarksObtained   DECIMAL(5,2)    NOT NULL CHECK (MarksObtained >= 0),
    Grade           NVARCHAR(2)     NULL,
    CONSTRAINT FK_Results_Students FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Results_ExamSchedule FOREIGN KEY (ExamID)
        REFERENCES ExamSchedule(ExamID)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT UQ_Result UNIQUE (StudentID, ExamID)
);
GO

-- ============================================================
-- 14. FeeStructure
-- ============================================================
CREATE TABLE FeeStructure (
    FeeStructureID  INT             PRIMARY KEY IDENTITY(1,1),
    ProgramID       INT             NOT NULL,
    FeeType         NVARCHAR(50)    NOT NULL
                    CHECK (FeeType IN ('Tuition','Hostel','Library','Exam','Lab','Miscellaneous')),
    Amount          DECIMAL(10,2)   NOT NULL CHECK (Amount > 0),
    Semester        NVARCHAR(20)    NULL,
    AcademicYear    NVARCHAR(10)    NOT NULL,
    CONSTRAINT FK_FeeStructure_Programs FOREIGN KEY (ProgramID)
        REFERENCES Programs(ProgramID)
        ON DELETE NO ACTION ON UPDATE CASCADE
);
GO

-- ============================================================
-- 15. FeePayments
-- NOTE: NO CASCADE on FeeStructureID to avoid multiple cascade paths
-- ============================================================
CREATE TABLE FeePayments (
    PaymentID       INT             PRIMARY KEY IDENTITY(1,1),
    StudentID       INT             NOT NULL,
    FeeStructureID  INT             NOT NULL,
    AmountPaid      DECIMAL(10,2)   NOT NULL CHECK (AmountPaid > 0),
    PaymentDate     DATE            NOT NULL DEFAULT GETDATE(),
    BankAccount     VARBINARY(256)  NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Paid'
                    CHECK (Status IN ('Paid','Partial','Pending','Overdue')),
    ReferenceNo     NVARCHAR(50)    NULL UNIQUE,
    CONSTRAINT FK_FeePayments_Students FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_FeePayments_FeeStructure FOREIGN KEY (FeeStructureID)
        REFERENCES FeeStructure(FeeStructureID)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);
GO

-- ============================================================
-- 16. LibraryItems
-- ============================================================
CREATE TABLE LibraryItems (
    ItemID          INT             PRIMARY KEY IDENTITY(1,1),
    Title           NVARCHAR(200)   NOT NULL,
    Author          NVARCHAR(100)   NOT NULL,
    ISBN            NVARCHAR(20)    NULL UNIQUE,
    Category        NVARCHAR(50)    NULL,
    Publisher       NVARCHAR(100)   NULL,
    PublishYear     INT             NULL CHECK (PublishYear >= 1800),
    CopiesTotal     INT             NOT NULL DEFAULT 1 CHECK (CopiesTotal > 0),
    CopiesAvailable INT             NOT NULL DEFAULT 1 CHECK (CopiesAvailable >= 0),
    CONSTRAINT CHK_Copies CHECK (CopiesAvailable <= CopiesTotal)
);
GO

-- ============================================================
-- 17. LibraryIssues
-- ============================================================
CREATE TABLE LibraryIssues (
    IssueID         INT             PRIMARY KEY IDENTITY(1,1),
    StudentID       INT             NOT NULL,
    ItemID          INT             NOT NULL,
    IssueDate       DATE            NOT NULL DEFAULT GETDATE(),
    DueDate         DATE            NOT NULL,
    ReturnDate      DATE            NULL,
    Fine            DECIMAL(8,2)    NOT NULL DEFAULT 0 CHECK (Fine >= 0),
    CONSTRAINT FK_LibraryIssues_Students FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_LibraryIssues_Items FOREIGN KEY (ItemID)
        REFERENCES LibraryItems(ItemID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CHK_DueDate CHECK (DueDate > IssueDate),
    CONSTRAINT CHK_ReturnDate CHECK (ReturnDate IS NULL OR ReturnDate >= IssueDate)
);
GO

-- ============================================================
-- 18. Hostels
-- ============================================================
CREATE TABLE Hostels (
    HostelID        INT             PRIMARY KEY IDENTITY(1,1),
    HostelName      NVARCHAR(50)    NOT NULL UNIQUE,
    HostelType      NVARCHAR(10)    NOT NULL CHECK (HostelType IN ('Male','Female')),
    TotalRooms      INT             NOT NULL CHECK (TotalRooms > 0),
    AvailableRooms  INT             NOT NULL CHECK (AvailableRooms >= 0),
    CONSTRAINT CHK_HostelRooms CHECK (AvailableRooms <= TotalRooms)
);
GO

-- ============================================================
-- 19. HostelAllotments
-- ============================================================
CREATE TABLE HostelAllotments (
    AllotmentID     INT             PRIMARY KEY IDENTITY(1,1),
    StudentID       INT             NOT NULL,
    HostelID        INT             NOT NULL,
    RoomNumber      NVARCHAR(10)    NOT NULL,
    AllotmentDate   DATE            NOT NULL DEFAULT GETDATE(),
    VacateDate      DATE            NULL,
    Status          NVARCHAR(20)    NOT NULL DEFAULT 'Active'
                    CHECK (Status IN ('Active','Vacated')),
    CONSTRAINT FK_HostelAllotments_Students FOREIGN KEY (StudentID)
        REFERENCES Students(StudentID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_HostelAllotments_Hostels FOREIGN KEY (HostelID)
        REFERENCES Hostels(HostelID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT UQ_HostelAllotment UNIQUE (StudentID, HostelID, RoomNumber)
);
GO

-- ============================================================
-- 20. AuditLog
-- ============================================================
CREATE TABLE AuditLog (
    LogID           INT             PRIMARY KEY IDENTITY(1,1),
    TableName       NVARCHAR(50)    NOT NULL,
    Operation       NVARCHAR(10)    NOT NULL CHECK (Operation IN ('INSERT','UPDATE','DELETE')),
    OldValue        NVARCHAR(MAX)   NULL,
    NewValue        NVARCHAR(MAX)   NULL,
    DBUser          NVARCHAR(100)   NOT NULL DEFAULT SYSTEM_USER,
    LoggedAt        DATETIME        NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- INDEXES
-- ============================================================
CREATE NONCLUSTERED INDEX IX_Enrollments_StudentID
    ON Enrollments(StudentID) INCLUDE (SectionID, Status);

CREATE NONCLUSTERED INDEX IX_Enrollments_SectionID
    ON Enrollments(SectionID) INCLUDE (StudentID, Status);

CREATE NONCLUSTERED INDEX IX_FeePayments_Date
    ON FeePayments(PaymentDate) INCLUDE (StudentID, AmountPaid, Status);

CREATE NONCLUSTERED INDEX IX_LibraryIssues_ReturnDate
    ON LibraryIssues(ReturnDate) INCLUDE (StudentID, ItemID, Fine);

CREATE NONCLUSTERED INDEX IX_Attendance_Student_Date
    ON AttendanceRecords(StudentID, AttendanceDate) INCLUDE (SectionID, Status);

-- Filtered index: active enrollments only
CREATE NONCLUSTERED INDEX IX_Enrollments_Active
    ON Enrollments(StudentID, SectionID)
    WHERE Status = 'Active';

-- Filtered covering index: pending/overdue fees
CREATE NONCLUSTERED INDEX IX_FeePayments_Pending
    ON FeePayments(Status, StudentID) INCLUDE (AmountPaid, PaymentDate)
    WHERE Status IN ('Pending','Overdue');
GO

-- ============================================================
-- FULL-TEXT SEARCH
-- ============================================================
-- IF NOT EXISTS (SELECT * FROM sys.fulltext_catalogs WHERE name = 'HiSUP_FT_Catalog')
--     CREATE FULLTEXT CATALOG HiSUP_FT_Catalog AS DEFAULT;
-- GO

-- Get the PK index name dynamically and create full-text index
-- DECLARE @pkName NVARCHAR(200);
-- SELECT @pkName = i.name
-- FROM sys.indexes i
-- WHERE i.object_id = OBJECT_ID('LibraryItems')
--   AND i.is_primary_key = 1;

-- DECLARE @sql NVARCHAR(500);
-- SET @sql = 'CREATE FULLTEXT INDEX ON LibraryItems(Title, Author)
--     KEY INDEX ' + QUOTENAME(@pkName) + '
--     ON HiSUP_FT_Catalog
--     WITH CHANGE_TRACKING AUTO;';
-- EXEC sp_executesql @sql;
-- GO

-- ============================================================
-- SEED DATA
-- ============================================================

-- Departments
INSERT INTO Departments (DeptName, DeptCode, EstablishedYear) VALUES
('Computer Science',        'CS',   1995),
('Electrical Engineering',  'EE',   1992),
('Mechanical Engineering',  'ME',   1993),
('Software Engineering',    'SE',   2005),
('Mathematics',             'MTH',  1990);
GO

-- Programs
INSERT INTO Programs (DepartmentID, ProgramName, Degree, DurationYears) VALUES
(1, 'Bachelor of Science in Computer Science',          'BS', 4),
(1, 'Master of Science in Computer Science',            'MS', 2),
(2, 'Bachelor of Science in Electrical Engineering',    'BS', 4),
(3, 'Bachelor of Science in Mechanical Engineering',    'BS', 4),
(4, 'Bachelor of Science in Software Engineering',      'BS', 4);
GO

-- UserAccounts (passwords are placeholder hashes - Identity will manage real ones)
INSERT INTO UserAccounts (Username, PasswordHash, Role) VALUES
('admin',       'PLACEHOLDER_HASH_admin',    'Admin'),
('finance01',   'PLACEHOLDER_HASH_finance',  'Finance'),
('faculty01',   'PLACEHOLDER_HASH_fac01',    'Faculty'),
('faculty02',   'PLACEHOLDER_HASH_fac02',    'Faculty'),
('faculty03',   'PLACEHOLDER_HASH_fac03',    'Faculty'),
('faculty04',   'PLACEHOLDER_HASH_fac04',    'Faculty'),
('student01',   'PLACEHOLDER_HASH_stu01',    'Student'),
('student02',   'PLACEHOLDER_HASH_stu02',    'Student'),
('student03',   'PLACEHOLDER_HASH_stu03',    'Student');
GO

-- Faculty (each has a unique UserAccountID)
INSERT INTO Faculty (DepartmentID, UserAccountID, FirstName, LastName, Email, Designation) VALUES
(1, 3,    'Ahmed',  'Khan',   'ahmed.khan@hitecuni.edu.pk',   'Assistant Professor'),
(1, 4,    'Sara',   'Malik',  'sara.malik@hitecuni.edu.pk',   'Lecturer'),
(2, 5,    'Usman',  'Ali',    'usman.ali@hitecuni.edu.pk',    'Associate Professor'),
(3, 6,    'Fatima', 'Zaidi',  'fatima.zaidi@hitecuni.edu.pk', 'Lecturer');
GO

-- Students
INSERT INTO Students (DepartmentID, ProgramID, UserAccountID, FirstName, LastName, Email, EnrollmentDate, CurrentSemester) VALUES
(1, 1, 7, 'Ali',    'Raza',   'ali.raza@student.hitecuni.edu.pk',    '2023-09-01', 4),
(1, 1, 8, 'Zara',   'Ahmed',  'zara.ahmed@student.hitecuni.edu.pk',  '2023-09-01', 4),
(1, 1, 9, 'Hassan', 'Nawaz',  'hassan.nawaz@student.hitecuni.edu.pk','2024-02-01', 2);
GO

-- Courses
INSERT INTO Courses (DepartmentID, PrerequisiteCourseID, CourseCode, CourseName, CreditHours) VALUES
(1, NULL, 'CS101', 'Introduction to Programming',  3),
(1, NULL, 'CS102', 'Discrete Mathematics',          3),
(1, 1,    'CS201', 'Data Structures',               3),
(1, 3,    'CS301', 'Algorithms',                    3),
(1, NULL, 'CS318', 'Database Management Systems',   3),
(1, 5,    'CS402', 'Advanced Database Management',  3),
(1, 3,    'CS310', 'Operating Systems',             3),
(2, NULL, 'EE101', 'Circuit Analysis',              3);
GO

-- Sections
INSERT INTO Sections (CourseID, FacultyID, SemesterLabel, SeatsTotal, SeatsAvailable, Room) VALUES
(5, 1, 'Spring-2025', 40, 37, 'CS-Lab-1'),
(6, 1, 'Spring-2025', 35, 32, 'CS-Lab-2'),
(3, 2, 'Spring-2025', 40, 38, 'CS-101'),
(7, 2, 'Spring-2025', 35, 33, 'CS-102');
GO

-- Enrollments
INSERT INTO Enrollments (StudentID, SectionID, EnrollmentDate, Status) VALUES
(1, 1, '2025-01-15', 'Active'),
(2, 1, '2025-01-15', 'Active'),
(3, 1, '2025-01-15', 'Active'),
(1, 2, '2025-01-15', 'Active'),
(2, 3, '2025-01-15', 'Active');
GO

-- Grades
INSERT INTO Grades (EnrollmentID, MarksObtained, LetterGrade, GradePoints) VALUES
(1, 85.00, 'A',  4.00),
(2, 72.00, 'B',  3.00),
(3, 60.00, 'C',  2.00);
GO

-- Hostels
INSERT INTO Hostels (HostelName, HostelType, TotalRooms, AvailableRooms) VALUES
('Boys Hostel Block A',  'Male',   100, 45),
('Boys Hostel Block B',  'Male',   80,  30),
('Girls Hostel Block A', 'Female', 60,  20);
GO

-- LibraryItems
INSERT INTO LibraryItems (Title, Author, ISBN, Category, Publisher, PublishYear, CopiesTotal, CopiesAvailable) VALUES
('Database System Concepts',    'Silberschatz, Korth', '9780073523323', 'Textbook',  'McGraw-Hill',  2019, 5, 4),
('T-SQL Fundamentals',          'Itzik Ben-Gan',       '9780135861493', 'Textbook',  'Microsoft',    2022, 3, 3),
('Clean Code',                  'Robert C. Martin',    '9780132350884', 'Reference', 'Prentice Hall',2008, 4, 2),
('ASP.NET Core in Action',      'Andrew Lock',         '9781633439160', 'Textbook',  'Manning',      2023, 2, 2),
('Introduction to Algorithms',  'Cormen, Leiserson',   '9780262046305', 'Textbook',  'MIT Press',    2022, 4, 3);
GO

-- FeeStructure
INSERT INTO FeeStructure (ProgramID, FeeType, Amount, Semester, AcademicYear) VALUES
(1, 'Tuition', 45000.00, 'Spring-2025', '2024-25'),
(1, 'Exam',     3000.00, 'Spring-2025', '2024-25'),
(1, 'Lab',      2000.00, 'Spring-2025', '2024-25'),
(2, 'Tuition', 60000.00, 'Spring-2025', '2024-25'),
(5, 'Tuition', 42000.00, 'Spring-2025', '2024-25');
GO

-- FeePayments
INSERT INTO FeePayments (StudentID, FeeStructureID, AmountPaid, PaymentDate, Status, ReferenceNo) VALUES
(1, 1, 45000.00, '2025-01-10', 'Paid',    'REF-2025-001'),
(1, 2,  3000.00, '2025-01-10', 'Paid',    'REF-2025-002'),
(2, 1, 45000.00, '2025-01-12', 'Paid',    'REF-2025-003'),
(3, 1, 20000.00, '2025-01-20', 'Partial', 'REF-2025-004');
GO

-- AttendanceRecords
INSERT INTO AttendanceRecords (StudentID, SectionID, AttendanceDate, Status) VALUES
(1, 1, '2025-01-20', 'Present'),
(1, 1, '2025-01-22', 'Present'),
(1, 1, '2025-01-24', 'Absent'),
(2, 1, '2025-01-20', 'Present'),
(2, 1, '2025-01-22', 'Present'),
(2, 1, '2025-01-24', 'Present'),
(3, 1, '2025-01-20', 'Absent'),
(3, 1, '2025-01-22', 'Present'),
(3, 1, '2025-01-24', 'Leave');
GO

-- ExamSchedule
INSERT INTO ExamSchedule (SectionID, ExamDateTime, Venue, ExamType, TotalMarks) VALUES
(1, '2025-03-15 09:00:00', 'Exam Hall A', 'Midterm', 50),
(2, '2025-03-16 09:00:00', 'Exam Hall B', 'Midterm', 50),
(1, '2025-05-20 09:00:00', 'Exam Hall A', 'Final',  100);
GO

-- Results
INSERT INTO Results (StudentID, ExamID, MarksObtained, Grade) VALUES
(1, 1, 42.00, 'A'),
(2, 1, 35.00, 'B'),
(3, 1, 28.00, 'C');
GO
