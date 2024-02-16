CREATE PROCEDURE [dbo].FormTaskTaskInsertNew
(
	@ExpandCollapse char(1),
	@isReportLevel char(1),
	@IsHidden bit,
	@ViewOrder int,
	@Name varchar(50),
	@DetailPriority int,
	@Description varchar(500),
	@Notes text,
	@DeadLine datetime,
	@DeadLineMet char(1),
	@BugCountQA int,
	@BugCountClient int,
	@TaskTypeID int,
	@Structure varchar(100),
	@EstDuration int,
	@TimeToEst int,
	@ActDuration int,
	@CollectivePriority varchar(20),
	@Priority int,
	@IndentLevel int,
	@ParentTaskID int,
	@DeveloperID int,
	@StatusID int,
	@IsLowestDisplayLevel bit,
	@inUse varchar(8)
)
AS
	SET NOCOUNT OFF;
INSERT INTO dbo.Task(ExpandCollapse, isReportLevel, IsHidden, ViewOrder, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, TaskTypeID, Structure, EstDuration, TimeToEst, ActDuration, CollectivePriority, Priority, IndentLevel, ParentTaskID, DeveloperID, StatusID, IsLowestDisplayLevel, inUse) VALUES (@ExpandCollapse, @isReportLevel, @IsHidden, @ViewOrder, @Name, @DetailPriority, @Description, @Notes, @DeadLine, @DeadLineMet, @BugCountQA, @BugCountClient, @TaskTypeID, @Structure, @EstDuration, @TimeToEst, @ActDuration, @CollectivePriority, @Priority, @IndentLevel, @ParentTaskID, @DeveloperID, @StatusID, @IsLowestDisplayLevel, @inUse);
	SELECT TaskID, ExpandCollapse, isReportLevel, IsHidden, ViewOrder, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, TaskTypeID, Structure, EstDuration, TimeToEst, ActDuration, CollectivePriority, Priority, IndentLevel, ParentTaskID, DeveloperID, StatusID, IsLowestDisplayLevel, inUse FROM dbo.Task WHERE (TaskID = @@IDENTITY)