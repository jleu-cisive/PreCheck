
CREATE PROCEDURE [dbo].FormTaskNewProjectInsert
(
	@Name varchar(200),
	@Description varchar(500),
	@Notes text,
	@Structure varchar(100),
	@DeadLine datetime,
	@TaskTypeID int,
	@DeveloperID int,
	@StatusID int,
	@inUse varchar(12),
	@Client varchar(20),
	@ProjectTypeID int,
	@PriorityLevelID int
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.TaskQueueNew(Name, Description, Notes, Structure, DeadLine, TaskTypeID, DeveloperID, StatusID, inUse, Client, ProjectTypeID, PriorityLevelID) VALUES (@Name, @Description, @Notes, @Structure, @DeadLine, @TaskTypeID, @DeveloperID, @StatusID, @inUse, @Client, @ProjectTypeID, @PriorityLevelID);
	SELECT TOP 0 TaskQueueNewID, Name, Description, Notes, Structure, DeadLine, TaskTypeID, DeveloperID, StatusID, inUse, Client, ProjectTypeID, PriorityLevelID FROM dbo.TaskQueueNew WHERE (TaskQueueNewID = @@IDENTITY)
