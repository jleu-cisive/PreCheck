CREATE PROCEDURE dbo.InUseTaskSet_NoCheck @UserID varchar(8) AS

DECLARE @TaskID int

	--not particular about which row to mark
	SELECT TOP 1 @TaskID=TaskID FROM Task
	
	UPDATE Task SET InUse=@UserID WHERE TaskID=@TaskID