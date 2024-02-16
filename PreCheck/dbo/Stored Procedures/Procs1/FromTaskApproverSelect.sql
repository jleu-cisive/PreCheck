

CREATE PROCEDURE [dbo].FromTaskApproverSelect
AS
	SET NOCOUNT ON;
SELECT TaskApproverID, TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, inUse, ViewOrder FROM dbo.TaskApprover ORDER BY ViewOrder

