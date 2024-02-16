
CREATE PROCEDURE [dbo].FormTaskEstimaterSelect
AS
	SET NOCOUNT ON;
SELECT TaskEstimaterTempID, TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, inUse, ViewOrder, IndentLevel FROM dbo.TaskEstimaterTemp ORDER BY ViewOrder
