


CREATE PROCEDURE [dbo].[FormTaskEstimaterNew] @UserID varchar(8) AS


--DELETE TaskEstimaterNew
--FROM   TaskEstimaterNew INNER JOIN task
--ON     ((task.TaskID = TaskEstimaterNew.taskid) AND (task.StatusID = TaskEstimaterNew.statusid) )

insert into taskestimatertemp (TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, 
DeadLineMet, TaskTypeID, ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, 
ROI, ParentTaskID, DeveloperID, Client, StatusID, IndentLevel)

SELECT TaskID, Name, DetailPriority, PriorityLevelID, Description, Notes, DeadLine, DeadLineMet, TaskTypeID, 
ProjectTypeID, Structure, EstDuration, EstCost, EstReturn, 
ROI, ParentTaskID, DeveloperID, Client, StatusID, IndentLevel FROM dbo.Task
-- WHERE (ParentTaskID IN (SELECT TaskID FROM dbo.Task WHERE (StatusID = 4) AND (IndentLevel = 0))) OR (IndentLevel = 0) AND (StatusID = 4) 
where statusid=4 and
		 (task.developerid=(SELECT     dbo.TaskResource.TaskResourceID
					FROM         dbo.TaskResource INNER JOIN
                     				 dbo.Users ON dbo.TaskResource.Name = dbo.Users.Name
					WHERE     (dbo.Users.UserID = @UserID)))
ORDER BY ViewOrder

--delete from taskestimaternew
--where taskid in (
	--select taskid
--	from taskestimaternew
--	group by taskid
--	having count( * ) > 1 ) and statusid = 4

update taskestimatertemp set inUse=@UserID where inUse is null
