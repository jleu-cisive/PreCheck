
CREATE PROCEDURE [dbo].FormTaskTaskSelect
AS
	SET NOCOUNT ON;
SELECT ExpandCollapse, isReportLevel, IsHidden, TaskID, Name, ViewOrder, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, TimeToEst, ActDuration, CollectivePriority, Priority, IndentLevel, ParentTaskID, DeveloperID, Client, StatusID, IsLowestDisplayLevel, inUse FROM dbo.Task
