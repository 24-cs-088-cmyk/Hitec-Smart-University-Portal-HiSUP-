-- 1. Drop the old foreign key constraints (only if they exist)
IF OBJECT_ID('FK_Students_UserAccounts', 'F') IS NOT NULL
    ALTER TABLE Students DROP CONSTRAINT FK_Students_UserAccounts;
IF OBJECT_ID('FK_Faculty_UserAccounts', 'F') IS NOT NULL
    ALTER TABLE Faculty DROP CONSTRAINT FK_Faculty_UserAccounts;
IF OBJECT_ID('FK_Staff_UserAccounts', 'F') IS NOT NULL
    ALTER TABLE Staff DROP CONSTRAINT FK_Staff_UserAccounts;

-- 2. Dynamically find and drop the auto-generated UNIQUE constraints on UserAccountID
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += N'ALTER TABLE Students DROP CONSTRAINT ' + kc.name + ';'
FROM sys.key_constraints kc
JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.type = 'UQ' AND kc.parent_object_id = OBJECT_ID('Students') AND c.name = 'UserAccountID';

SELECT @sql += N'ALTER TABLE Faculty DROP CONSTRAINT ' + kc.name + ';'
FROM sys.key_constraints kc
JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.type = 'UQ' AND kc.parent_object_id = OBJECT_ID('Faculty') AND c.name = 'UserAccountID';

SELECT @sql += N'ALTER TABLE Staff DROP CONSTRAINT ' + kc.name + ';'
FROM sys.key_constraints kc
JOIN sys.index_columns ic ON kc.parent_object_id = ic.object_id AND kc.unique_index_id = ic.index_id
JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE kc.type = 'UQ' AND kc.parent_object_id = OBJECT_ID('Staff') AND c.name = 'UserAccountID';

EXEC sp_executesql @sql;

-- 3. Clear out the old integer-based IDs 
UPDATE Students SET UserAccountID = NULL;
UPDATE Faculty SET UserAccountID = NULL;
UPDATE Staff SET UserAccountID = NULL;

-- 4. Change the column types to NVARCHAR(450)
ALTER TABLE Students ALTER COLUMN UserAccountID NVARCHAR(450);
ALTER TABLE Faculty ALTER COLUMN UserAccountID NVARCHAR(450);
ALTER TABLE Staff ALTER COLUMN UserAccountID NVARCHAR(450);

-- 5. Add the new foreign key constraints (only if they don't already exist)
IF OBJECT_ID('FK_Students_AspNetUsers', 'F') IS NULL
    ALTER TABLE Students ADD CONSTRAINT FK_Students_AspNetUsers FOREIGN KEY (UserAccountID) REFERENCES AspNetUsers(Id);
IF OBJECT_ID('FK_Faculty_AspNetUsers', 'F') IS NULL
    ALTER TABLE Faculty ADD CONSTRAINT FK_Faculty_AspNetUsers FOREIGN KEY (UserAccountID) REFERENCES AspNetUsers(Id);
IF OBJECT_ID('FK_Staff_AspNetUsers', 'F') IS NULL
    ALTER TABLE Staff ADD CONSTRAINT FK_Staff_AspNetUsers FOREIGN KEY (UserAccountID) REFERENCES AspNetUsers(Id);
