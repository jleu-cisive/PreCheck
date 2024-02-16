CREATE PROCEDURE dbo.FormTaskOnDeveloperID
@DeveloperID int,
@TaskID int
AS
	SET NOCOUNT ON;

SELECT TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, ProjectTypeID, 
Structure, EstDuration, EstCost, EstReturn, ROI, ParentTaskID, DeveloperID, Client, StatusID, inUse, ViewOrder FROM Task
WHERE DeveloperID = @DeveloperID and TaskID <> @TaskID and StatusID <7 and StatusID<>2 and TaskTypeID=1 
and ( DeadLineMet is null or DeadLineMet = '')  and DeadLine is not null
order by  PriorityLevelID desc