
CREATE PROCEDURE [dbo].[FormTaskApproverNewb4]  @UserID varchar(8) AS

DELETE TaskApprover
FROM   TaskApprover INNER JOIN task
ON     ((task.TaskID = TaskApprover.taskid) AND (task.StatusID = TaskApprover.statusid))

insert into TaskApprover (TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, 
DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, 
ROI, ParentTaskID, DeveloperID, Client, StatusID)

SELECT TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, 
ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, 
ROI, ParentTaskID, DeveloperID, Client, StatusID FROM dbo.Task
-- WHERE (ParentTaskID IN (SELECT TaskID FROM dbo.Task WHERE (StatusID = 4) AND (IndentLevel = 0))) OR (IndentLevel = 0) AND (StatusID = 4) 
where statusid=5
ORDER BY ViewOrder

delete from TaskApprover
where taskid in (
	select taskid
	from TaskApprover
	group by taskid
	having count( * ) > 1 ) and statusid = 5

delete from TaskApprover
where ParentTaskID  in (
	select taskid
	from Task
	where statusid = 4)

update TaskApprover set inUse=@UserID where inUse is null