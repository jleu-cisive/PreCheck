CREATE PROCEDURE [dbo].FormTaskTaskSelectNew
AS
	SET NOCOUNT ON;
SELECT TaskID, ExpandCollapse, isReportLevel, IsHidden, ViewOrder, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, TaskTypeID, Structure, EstDuration, TimeToEst, ActDuration, CollectivePriority, Priority, IndentLevel, ParentTaskID, DeveloperID, StatusID, IsLowestDisplayLevel, inUse FROM dbo.Task