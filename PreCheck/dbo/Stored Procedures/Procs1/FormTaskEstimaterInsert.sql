
CREATE PROCEDURE [dbo].FormTaskEstimaterInsert
(
	@TaskID int,
	@Name varchar(200),
	@DetailPriority int,
	@PriorityLevelID int,
	@Description varchar(500),
	@Notes text,
	@DeadLine datetime,
	@DeadLineMet char(1),
	@TaskTypeID int,
	@ProjectTypeID int,
	@Structure varchar(100),
	@EstDuration int,
	@EstCost decimal(18,2),
	@EstReturn decimal(18,2),
	@ROI decimal(18,2),
	@ParentTaskID int,
	@DeveloperID int,
	@Client varchar(20),
	@StatusID int,
	@inUse varchar(12),
	@ViewOrder int
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.TaskEstimaterTemp(TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, inUse, ViewOrder) VALUES (@TaskID, @Name, @DetailPriority, @PriorityLevelID, @Description, @Notes, @DeadLine, @DeadLineMet, @TaskTypeID, @ProjectTypeID, @Structure, @EstDuration, @EstCost, @EstReturn, @ROI, @ParentTaskID, @DeveloperID, @Client, @StatusID, @inUse, @ViewOrder);
	SELECT TaskEstimaterTempID, TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, inUse, ViewOrder FROM dbo.TaskEstimaterTemp WHERE (TaskEstimaterTempID = @@IDENTITY) ORDER BY ViewOrder
