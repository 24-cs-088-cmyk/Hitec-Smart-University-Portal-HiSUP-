IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
CREATE TABLE [AspNetRoles] (
    [Id] nvarchar(450) NOT NULL,
    [Name] nvarchar(256) NULL,
    [NormalizedName] nvarchar(256) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([Id])
);

CREATE TABLE [AspNetUsers] (
    [Id] nvarchar(450) NOT NULL,
    [FullName] nvarchar(max) NULL,
    [Role] nvarchar(max) NOT NULL,
    [UserName] nvarchar(256) NULL,
    [NormalizedUserName] nvarchar(256) NULL,
    [Email] nvarchar(256) NULL,
    [NormalizedEmail] nvarchar(256) NULL,
    [EmailConfirmed] bit NOT NULL,
    [PasswordHash] nvarchar(max) NULL,
    [SecurityStamp] nvarchar(max) NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    [PhoneNumber] nvarchar(max) NULL,
    [PhoneNumberConfirmed] bit NOT NULL,
    [TwoFactorEnabled] bit NOT NULL,
    [LockoutEnd] datetimeoffset NULL,
    [LockoutEnabled] bit NOT NULL,
    [AccessFailedCount] int NOT NULL,
    CONSTRAINT [PK_AspNetUsers] PRIMARY KEY ([Id])
);

CREATE TABLE [AuditLog] (
    [LogID] int NOT NULL IDENTITY,
    [TableName] nvarchar(50) NOT NULL,
    [Operation] nvarchar(10) NOT NULL,
    [OldValue] nvarchar(max) NULL,
    [NewValue] nvarchar(max) NULL,
    [DBUser] nvarchar(100) NOT NULL,
    [LoggedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_AuditLog] PRIMARY KEY ([LogID])
);

CREATE TABLE [Departments] (
    [DepartmentID] int NOT NULL IDENTITY,
    [DeptName] nvarchar(100) NOT NULL,
    [DeptCode] nvarchar(10) NOT NULL,
    [EstablishedYear] int NULL,
    [CreatedAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Departments] PRIMARY KEY ([DepartmentID])
);

CREATE TABLE [LibraryItems] (
    [ItemID] int NOT NULL IDENTITY,
    [Title] nvarchar(200) NOT NULL,
    [Author] nvarchar(100) NOT NULL,
    [ISBN] nvarchar(20) NULL,
    [Category] nvarchar(max) NULL,
    [Publisher] nvarchar(max) NULL,
    [PublishYear] int NULL,
    [CopiesTotal] int NOT NULL,
    [CopiesAvailable] int NOT NULL,
    CONSTRAINT [PK_LibraryItems] PRIMARY KEY ([ItemID])
);

CREATE TABLE [AspNetRoleClaims] (
    [Id] int NOT NULL IDENTITY,
    [RoleId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserClaims] (
    [Id] int NOT NULL IDENTITY,
    [UserId] nvarchar(450) NOT NULL,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserLogins] (
    [LoginProvider] nvarchar(450) NOT NULL,
    [ProviderKey] nvarchar(450) NOT NULL,
    [ProviderDisplayName] nvarchar(max) NULL,
    [UserId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
    CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserRoles] (
    [UserId] nvarchar(450) NOT NULL,
    [RoleId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]),
    CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [AspNetUserTokens] (
    [UserId] nvarchar(450) NOT NULL,
    [LoginProvider] nvarchar(450) NOT NULL,
    [Name] nvarchar(450) NOT NULL,
    [Value] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
    CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [AspNetUsers] ([Id]) ON DELETE CASCADE
);

CREATE TABLE [Courses] (
    [CourseID] int NOT NULL IDENTITY,
    [DepartmentID] int NOT NULL,
    [PrerequisiteCourseID] int NULL,
    [CourseCode] nvarchar(10) NOT NULL,
    [CourseName] nvarchar(100) NOT NULL,
    [CreditHours] int NOT NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_Courses] PRIMARY KEY ([CourseID]),
    CONSTRAINT [FK_Courses_Courses_PrerequisiteCourseID] FOREIGN KEY ([PrerequisiteCourseID]) REFERENCES [Courses] ([CourseID]),
    CONSTRAINT [FK_Courses_Departments_DepartmentID] FOREIGN KEY ([DepartmentID]) REFERENCES [Departments] ([DepartmentID]) ON DELETE CASCADE
);

CREATE TABLE [Faculty] (
    [FacultyID] int NOT NULL IDENTITY,
    [DepartmentID] int NOT NULL,
    [UserAccountID] nvarchar(max) NULL,
    [FirstName] nvarchar(50) NOT NULL,
    [LastName] nvarchar(50) NOT NULL,
    [Email] nvarchar(450) NOT NULL,
    [Designation] nvarchar(max) NOT NULL,
    [JoiningDate] datetime2 NOT NULL,
    CONSTRAINT [PK_Faculty] PRIMARY KEY ([FacultyID]),
    CONSTRAINT [FK_Faculty_Departments_DepartmentID] FOREIGN KEY ([DepartmentID]) REFERENCES [Departments] ([DepartmentID]) ON DELETE CASCADE
);

CREATE TABLE [Programs] (
    [ProgramID] int NOT NULL IDENTITY,
    [DepartmentID] int NOT NULL,
    [ProgramName] nvarchar(100) NOT NULL,
    [Degree] nvarchar(20) NOT NULL,
    [DurationYears] int NOT NULL,
    CONSTRAINT [PK_Programs] PRIMARY KEY ([ProgramID]),
    CONSTRAINT [FK_Programs_Departments_DepartmentID] FOREIGN KEY ([DepartmentID]) REFERENCES [Departments] ([DepartmentID]) ON DELETE CASCADE
);

CREATE TABLE [Sections] (
    [SectionID] int NOT NULL IDENTITY,
    [CourseID] int NOT NULL,
    [FacultyID] int NOT NULL,
    [SemesterLabel] nvarchar(20) NOT NULL,
    [SeatsTotal] int NOT NULL,
    [SeatsAvailable] int NOT NULL,
    [Room] nvarchar(max) NULL,
    [Schedule] nvarchar(max) NULL,
    CONSTRAINT [PK_Sections] PRIMARY KEY ([SectionID]),
    CONSTRAINT [FK_Sections_Courses_CourseID] FOREIGN KEY ([CourseID]) REFERENCES [Courses] ([CourseID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Sections_Faculty_FacultyID] FOREIGN KEY ([FacultyID]) REFERENCES [Faculty] ([FacultyID]) ON DELETE CASCADE
);

CREATE TABLE [FeeStructure] (
    [FeeStructureID] int NOT NULL IDENTITY,
    [ProgramID] int NOT NULL,
    [FeeType] nvarchar(50) NOT NULL,
    [Amount] decimal(10,2) NOT NULL,
    [Semester] nvarchar(max) NULL,
    [AcademicYear] nvarchar(10) NOT NULL,
    CONSTRAINT [PK_FeeStructure] PRIMARY KEY ([FeeStructureID]),
    CONSTRAINT [FK_FeeStructure_Programs_ProgramID] FOREIGN KEY ([ProgramID]) REFERENCES [Programs] ([ProgramID]) ON DELETE CASCADE
);

CREATE TABLE [Students] (
    [StudentID] int NOT NULL IDENTITY,
    [DepartmentID] int NOT NULL,
    [ProgramID] int NOT NULL,
    [UserAccountID] nvarchar(max) NULL,
    [FirstName] nvarchar(50) NOT NULL,
    [LastName] nvarchar(50) NOT NULL,
    [Email] nvarchar(100) NOT NULL,
    [CNIC] varbinary(max) NULL,
    [EnrollmentDate] datetime2 NOT NULL,
    [CurrentSemester] int NOT NULL,
    [CGPA] decimal(3,2) NOT NULL,
    [IsActive] bit NOT NULL,
    CONSTRAINT [PK_Students] PRIMARY KEY ([StudentID]),
    CONSTRAINT [FK_Students_Departments_DepartmentID] FOREIGN KEY ([DepartmentID]) REFERENCES [Departments] ([DepartmentID]) ON DELETE CASCADE,
    CONSTRAINT [FK_Students_Programs_ProgramID] FOREIGN KEY ([ProgramID]) REFERENCES [Programs] ([ProgramID]) ON DELETE CASCADE
);

CREATE TABLE [AttendanceRecords] (
    [AttendanceID] int NOT NULL IDENTITY,
    [StudentID] int NOT NULL,
    [SectionID] int NOT NULL,
    [AttendanceDate] datetime2 NOT NULL,
    [Status] nvarchar(10) NOT NULL,
    CONSTRAINT [PK_AttendanceRecords] PRIMARY KEY ([AttendanceID]),
    CONSTRAINT [FK_AttendanceRecords_Sections_SectionID] FOREIGN KEY ([SectionID]) REFERENCES [Sections] ([SectionID]),
    CONSTRAINT [FK_AttendanceRecords_Students_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [Students] ([StudentID]) ON DELETE CASCADE
);

CREATE TABLE [Enrollments] (
    [EnrollmentID] int NOT NULL IDENTITY,
    [StudentID] int NOT NULL,
    [SectionID] int NOT NULL,
    [EnrollmentDate] datetime2 NOT NULL,
    [Status] nvarchar(20) NOT NULL,
    CONSTRAINT [PK_Enrollments] PRIMARY KEY ([EnrollmentID]),
    CONSTRAINT [FK_Enrollments_Sections_SectionID] FOREIGN KEY ([SectionID]) REFERENCES [Sections] ([SectionID]),
    CONSTRAINT [FK_Enrollments_Students_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [Students] ([StudentID]) ON DELETE CASCADE
);

CREATE TABLE [FeePayments] (
    [PaymentID] int NOT NULL IDENTITY,
    [StudentID] int NOT NULL,
    [FeeStructureID] int NOT NULL,
    [AmountPaid] decimal(10,2) NOT NULL,
    [PaymentDate] datetime2 NOT NULL,
    [BankAccount] varbinary(max) NULL,
    [Status] nvarchar(20) NOT NULL,
    [ReferenceNo] nvarchar(50) NULL,
    CONSTRAINT [PK_FeePayments] PRIMARY KEY ([PaymentID]),
    CONSTRAINT [FK_FeePayments_FeeStructure_FeeStructureID] FOREIGN KEY ([FeeStructureID]) REFERENCES [FeeStructure] ([FeeStructureID]),
    CONSTRAINT [FK_FeePayments_Students_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [Students] ([StudentID]) ON DELETE CASCADE
);

CREATE TABLE [LibraryIssues] (
    [IssueID] int NOT NULL IDENTITY,
    [StudentID] int NOT NULL,
    [ItemID] int NOT NULL,
    [IssueDate] datetime2 NOT NULL,
    [DueDate] datetime2 NOT NULL,
    [ReturnDate] datetime2 NULL,
    [Fine] decimal(8,2) NOT NULL,
    CONSTRAINT [PK_LibraryIssues] PRIMARY KEY ([IssueID]),
    CONSTRAINT [FK_LibraryIssues_LibraryItems_ItemID] FOREIGN KEY ([ItemID]) REFERENCES [LibraryItems] ([ItemID]) ON DELETE CASCADE,
    CONSTRAINT [FK_LibraryIssues_Students_StudentID] FOREIGN KEY ([StudentID]) REFERENCES [Students] ([StudentID]) ON DELETE CASCADE
);

CREATE TABLE [Grades] (
    [GradeID] int NOT NULL IDENTITY,
    [EnrollmentID] int NOT NULL,
    [MarksObtained] decimal(5,2) NOT NULL,
    [LetterGrade] nvarchar(2) NULL,
    [GradePoints] decimal(3,2) NULL,
    [EnteredAt] datetime2 NOT NULL,
    CONSTRAINT [PK_Grades] PRIMARY KEY ([GradeID]),
    CONSTRAINT [FK_Grades_Enrollments_EnrollmentID] FOREIGN KEY ([EnrollmentID]) REFERENCES [Enrollments] ([EnrollmentID]) ON DELETE CASCADE
);

CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);

CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;

CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);

CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);

CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);

CREATE INDEX [EmailIndex] ON [AspNetUsers] ([NormalizedEmail]);

CREATE UNIQUE INDEX [UserNameIndex] ON [AspNetUsers] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;

CREATE INDEX [IX_AttendanceRecords_SectionID] ON [AttendanceRecords] ([SectionID]);

CREATE INDEX [IX_AttendanceRecords_StudentID] ON [AttendanceRecords] ([StudentID]);

CREATE INDEX [IX_Courses_DepartmentID] ON [Courses] ([DepartmentID]);

CREATE INDEX [IX_Courses_PrerequisiteCourseID] ON [Courses] ([PrerequisiteCourseID]);

CREATE INDEX [IX_Enrollments_SectionID] ON [Enrollments] ([SectionID]);

CREATE UNIQUE INDEX [IX_Enrollments_StudentID_SectionID] ON [Enrollments] ([StudentID], [SectionID]);

CREATE INDEX [IX_Faculty_DepartmentID] ON [Faculty] ([DepartmentID]);

CREATE UNIQUE INDEX [IX_Faculty_Email] ON [Faculty] ([Email]);

CREATE INDEX [IX_FeePayments_FeeStructureID] ON [FeePayments] ([FeeStructureID]);

CREATE INDEX [IX_FeePayments_StudentID] ON [FeePayments] ([StudentID]);

CREATE INDEX [IX_FeeStructure_ProgramID] ON [FeeStructure] ([ProgramID]);

CREATE UNIQUE INDEX [IX_Grades_EnrollmentID] ON [Grades] ([EnrollmentID]);

CREATE INDEX [IX_LibraryIssues_ItemID] ON [LibraryIssues] ([ItemID]);

CREATE INDEX [IX_LibraryIssues_StudentID] ON [LibraryIssues] ([StudentID]);

CREATE INDEX [IX_Programs_DepartmentID] ON [Programs] ([DepartmentID]);

CREATE INDEX [IX_Sections_CourseID] ON [Sections] ([CourseID]);

CREATE INDEX [IX_Sections_FacultyID] ON [Sections] ([FacultyID]);

CREATE INDEX [IX_Students_DepartmentID] ON [Students] ([DepartmentID]);

CREATE UNIQUE INDEX [IX_Students_Email] ON [Students] ([Email]);

CREATE INDEX [IX_Students_ProgramID] ON [Students] ([ProgramID]);

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20260614123729_InitialIdentitySetup', N'10.0.8');

COMMIT;
GO

