
CREATE PROCEDURE [dbo].FormTaskNewProjectDelete
(
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
	@Original_inUse varchar(12)
)
AS
	SET NOCOUNT OFF;
DELETE FROM dbo.TaskQueueNew WHERE (TaskQueueNewID = @Original_TaskQueueNewID) AND (Client = @Original_Client OR @Original_Client IS NULL AND Client IS NULL) AND (DeadLine = @Original_DeadLine OR @Original_DeadLine IS NULL AND DeadLine IS NULL) AND (Description = @Original_Description OR @Original_Description IS NULL AND Description IS NULL) AND (DeveloperID = @Original_DeveloperID) AND (Name = @Original_Name) AND (PriorityLevelID = @Original_PriorityLevelID OR @Original_PriorityLevelID IS NULL AND PriorityLevelID IS NULL) AND (ProjectTypeID = @Original_ProjectTypeID OR @Original_ProjectTypeID IS NULL AND ProjectTypeID IS NULL) AND (StatusID = @Original_StatusID) AND (Structure = @Original_Structure OR @Original_Structure IS NULL AND Structure IS NULL) AND (TaskTypeID = @Original_TaskTypeID) AND (inUse = @Original_inUse OR @Original_inUse IS NULL AND inUse IS NULL)
