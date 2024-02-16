
CREATE PROCEDURE [dbo].[UpdateTaskApprover] AS

-->>>>>>>>>>>>>>>>>>>>>>>added on 2/23/06
UPDATE    dbo.TaskApprover
SET              StatusID = 6
WHERE     (StatusID = 5) AND (ParentTaskID IN
                          (SELECT     taskid
                            FROM          taskapprover
                            WHERE      parenttaskid = 0 AND statusid = 6))
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

UPDATE    Task
SET          StatusID = e.StatusID, PriorityLevelID=e.PriorityLevelID
FROM         Task t, TaskApprover e
WHERE     t .TaskID = e.TaskID

--=========Update DeadLine==================

UPDATE    Task
SET          DeadLine = e.DeadLine
FROM         Task t, TaskApprover e
WHERE     t .TaskID = e.TaskID

--=========now update the history table

	INSERT INTO dbo.TaskHistory
		SELECT  distinct   t.TaskID, t.StatusID, e.inUse AS changedby, GETDATE() AS changedDate
		FROM       Task t, TaskApprover e
		WHERE     (t.TaskID = e.TaskID)

--==========added on 2/14/06 to fix kevin's name
UPDATE    dbo.TaskHistory
SET              ChangedBy = 'KFargason'
WHERE     (ChangedBy = 'KFargaso')

update dbo.task set inuse=null
where inuse is not null