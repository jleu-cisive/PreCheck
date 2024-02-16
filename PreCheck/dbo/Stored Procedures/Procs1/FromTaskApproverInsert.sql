


CREATE PROCEDURE [dbo].[FromTaskApproverInsert]
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
INSERT INTO dbo.TaskApprover(TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, inUse, ViewOrder) VALUES (@TaskID, @Name, @DetailPriority, @PriorityLevelID, @Description, @Notes, @DeadLine, @DeadLineMet, @TaskTypeID, @ProjectTypeID, @Structure, @EstDuration, @EstCost, @EstReturn, @ROI, @ParentTaskID, @DeveloperID, @Client, @StatusID, @inUse, @ViewOrder);
	SELECT TaskApproverID, TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, inUse, ViewOrder FROM dbo.TaskApprover WHERE (TaskApproverID = @@IDENTITY) ORDER BY ViewOrder


