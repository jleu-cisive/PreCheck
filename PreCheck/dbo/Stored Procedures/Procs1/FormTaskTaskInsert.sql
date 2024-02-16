
CREATE PROCEDURE [dbo].FormTaskTaskInsert
(
	@ExpandCollapse char(1),
	@isReportLevel char(1),
	@IsHidden bit,
	@Name varchar(200),
	@ViewOrder int,
	@DetailPriority int,
	@PriorityLevelID int,
	@Description varchar(500),
	@Notes text,
	@DeadLine datetime,
	@DeadLineMet char(1),
	@BugCountQA int,
	@BugCountClient int,
	@TaskTypeID int,
	@ProjectTypeID int,
	@Structure varchar(100),
	@EstDuration int,
	@EstCost decimal(18,2),
	@EstReturn decimal(18,2),
	@ROI decimal(18,2),
	@TimeToEst int,
	@ActDuration int,
	@CollectivePriority varchar(20),
	@Priority int,
	@IndentLevel int,
	@ParentTaskID int,
	@DeveloperID int,
	@Client varchar(20),
	@StatusID int,
	@IsLowestDisplayLevel bit,
	@inUse varchar(12)
)
AS
	SET NOCOUNT ON;
INSERT INTO dbo.Task(ExpandCollapse, isReportLevel, IsHidden, Name, ViewOrder, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, TimeToEst, ActDuration, CollectivePriority, Priority, IndentLevel, ParentTaskID, DeveloperID, Client, StatusID, IsLowestDisplayLevel, inUse) VALUES (@ExpandCollapse, @isReportLevel, @IsHidden, @Name, @ViewOrder, @DetailPriority, @PriorityLevelID, @Description, @Notes, @DeadLine, @DeadLineMet, @BugCountQA, @BugCountClient, @TaskTypeID, @ProjectTypeID, @Structure, @EstDuration, @EstCost, @EstReturn, @ROI, @TimeToEst, @ActDuration, @CollectivePriority, @Priority, @IndentLevel, @ParentTaskID, @DeveloperID, @Client, @StatusID, @IsLowestDisplayLevel, @inUse);
	SELECT ExpandCollapse, isReportLevel, IsHidden, TaskID, Name, ViewOrder, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, TimeToEst, ActDuration, CollectivePriority, Priority, IndentLevel, ParentTaskID, DeveloperID, Client, StatusID, IsLowestDisplayLevel, inUse FROM dbo.Task WHERE (TaskID = @@IDENTITY)
