
CREATE PROCEDURE [dbo].FormTaskNewProjectUpdate
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
	@PriorityLevelID int,
	@Original_TaskQueueNewID int,
	@Original_Client varchar(20),
	@Original_DeadLine datetime,
	@Original_Description varchar(500),
	@Original_DeveloperID int,
	@Original_Name varchar(200),
	@Original_PriorityLevelID int,
	@Original_ProjectTypeID int,
	@Original_StatusID int,
	@Original_Structure varchar(100),
	@Original_TaskTypeID int,
	@Original_inUse varchar(12),
	@TaskQueueNewID int
)
AS
	SET NOCOUNT OFF;
UPDATE dbo.TaskQueueNew SET Name = @Name, Description = @Description, Notes = @Notes, Structure = @Structure, DeadLine = @DeadLine, TaskTypeID = @TaskTypeID, DeveloperID = @DeveloperID, StatusID = @StatusID, inUse = @inUse, Client = @Client, ProjectTypeID = @ProjectTypeID, PriorityLevelID = @PriorityLevelID WHERE (TaskQueueNewID = @Original_TaskQueueNewID) AND (Client = @Original_Client OR @Original_Client IS NULL AND Client IS NULL) AND (DeadLine = @Original_DeadLine OR @Original_DeadLine IS NULL AND DeadLine IS NULL) AND (Description = @Original_Description OR @Original_Description IS NULL AND Description IS NULL) AND (DeveloperID = @Original_DeveloperID) AND (Name = @Original_Name) AND (PriorityLevelID = @Original_PriorityLevelID OR @Original_PriorityLevelID IS NULL AND PriorityLevelID IS NULL) AND (ProjectTypeID = @Original_ProjectTypeID OR @Original_ProjectTypeID IS NULL AND ProjectTypeID IS NULL) AND (StatusID = @Original_StatusID) AND (Structure = @Original_Structure OR @Original_Structure IS NULL AND Structure IS NULL) AND (TaskTypeID = @Original_TaskTypeID) AND (inUse = @Original_inUse OR @Original_inUse IS NULL AND inUse IS NULL);
	SELECT TOP 0 TaskQueueNewID, Name, Description, Notes, Structure, DeadLine, TaskTypeID, DeveloperID, StatusID, inUse, Client, ProjectTypeID, PriorityLevelID FROM dbo.TaskQueueNew WHERE (TaskQueueNewID = @TaskQueueNewID)
