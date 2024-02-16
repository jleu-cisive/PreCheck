
CREATE PROCEDURE [dbo].FormTaskAddBugInsert
(
	@ExpandCollapse char(1),
	@IsHidden bit,
	@Name varchar(200),
	@DetailPriority int,
	@Description varchar(500),
	@Notes text,
	@DeadLine datetime,
	@DeadLineMet char(1),
	@BugCountQA int,
	@BugCountClient int,
	@EstDuration int,
	@TimeToEst int,
	@ActDuration int,
	@CollectivePriority varchar(20),
	@Priority int,
	@ViewOrder int,
	@IndentLevel int,
	@ParentTaskID int,
	@DeveloperID int,
	@StatusID int,
	@TaskTypeID int,
	@IsLowestDisplayLevel bit,
	@isReportLevel char(1),
	@inUse varchar(12),
	@Structure varchar(100),
	@ProjectTypeID int,
	@Client varchar(20),
	@EstCost decimal(18,2),
	@EstReturn decimal(18,2),
	@ROI decimal(18,2)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.TaskQueue(ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI) VALUES (@ExpandCollapse, @IsHidden, @Name, @DetailPriority, @Description, @Notes, @DeadLine, @DeadLineMet, @BugCountQA, @BugCountClient, @EstDuration, @TimeToEst, @ActDuration, @CollectivePriority, @Priority, @ViewOrder, @IndentLevel, @ParentTaskID, @DeveloperID, @StatusID, @TaskTypeID, @IsLowestDisplayLevel, @isReportLevel, @inUse, @Structure, @ProjectTypeID, @Client, @EstCost, @EstReturn, @ROI);
	SELECT TaskQueueID, ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI FROM dbo.TaskQueue WHERE (TaskQueueID = @@IDENTITY)
