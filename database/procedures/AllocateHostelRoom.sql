-- ============================================================
-- AllocateHostelRoom.sql
-- Allocates a hostel room with ACID transaction
-- ============================================================
CREATE OR ALTER PROCEDURE AllocateHostelRoom
    @StudentID      INT,
    @HostelID       INT,
    @RoomNumber     NVARCHAR(10),
    @AllotmentID    INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Students WHERE StudentID = @StudentID AND IsActive = 1)
            THROW 50060, 'Student not found or inactive.', 1;
        IF NOT EXISTS (SELECT 1 FROM Hostels WHERE HostelID = @HostelID)
            THROW 50061, 'Hostel not found.', 1;
        IF (SELECT AvailableRooms FROM Hostels WHERE HostelID = @HostelID) <= 0
            THROW 50062, 'No rooms available in this hostel.', 1;
        IF EXISTS (SELECT 1 FROM HostelAllotments
                   WHERE StudentID = @StudentID AND Status = 'Active')
            THROW 50063, 'Student already has an active hostel allotment.', 1;

        BEGIN TRANSACTION;
            INSERT INTO HostelAllotments (StudentID, HostelID, RoomNumber, AllotmentDate, Status)
            VALUES (@StudentID, @HostelID, @RoomNumber, GETDATE(), 'Active');
            SET @AllotmentID = SCOPE_IDENTITY();

            UPDATE Hostels
            SET AvailableRooms = AvailableRooms - 1
            WHERE HostelID = @HostelID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
