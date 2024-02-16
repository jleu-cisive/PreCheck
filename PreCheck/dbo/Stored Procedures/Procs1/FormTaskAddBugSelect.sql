
CREATE PROCEDURE [dbo].FormTaskAddBugSelect
AS
	SET NOCOUNT ON;
SELECT TaskQueueID, ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI FROM dbo.TaskQueue
