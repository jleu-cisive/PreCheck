

CREATE  PROCEDURE [dbo].[UpdateTaskEstimater] AS
DECLARE  @taskid  int, @parentid int, @vieworder int,   @maxTaskid int, @ptaskid int,
	 @myVieworder int, @newRowCount int, @TaskEstimaterNewID int

set @parentid=(select top 1 taskid from taskestimaternew where taskid<>0 )
set @newRowCount=0
--=======================================
--update the indentLevel now
UPDATE    dbo.TaskEstimaterNew
SET     IndentLevel = 0,  ExpandCollapse = ' ', IsHidden = 0, ParentTaskID = 0, 
	isReportLevel = ' ', IsLowestDisplayLevel=0, Priority=0,DetailPriority=0,
	BugCountQA=0, BugCountClient=0, TimeToEst=0,ActDuration=0,CollectivePriority=0,
	EstReturn=0,ROI=0--EstDuration=0,EstCost=0,
WHERE     (TaskTypeID = 1 )

UPDATE    dbo.TaskEstimaterNew
SET     IndentLevel = 1,  ExpandCollapse = ' ', IsHidden = 0, ParentTaskID = 0, 
	isReportLevel = ' ', IsLowestDisplayLevel=0, Priority=0,DetailPriority=0,
	BugCountQA=0, BugCountClient=0, TimeToEst=0,ActDuration=0,CollectivePriority=0,
	EstReturn=0,ROI=0--EstDuration=0,EstCost=0,
WHERE     (TaskTypeID = 2 )

UPDATE    dbo.TaskEstimaterNew
SET     IndentLevel = 2,  ExpandCollapse = ' ', IsHidden = 0, ParentTaskID = 0, 
	isReportLevel = ' ',  IsLowestDisplayLevel=0, Priority=0,DetailPriority=0,
	BugCountQA=0, BugCountClient=0, TimeToEst=0,ActDuration=0,CollectivePriority=0,
	EstReturn=0,ROI=0
WHERE     (TaskTypeID = 3 or TaskTypeID = 4) 

UPDATE    dbo.TaskEstimaterNew
SET              Name = '      ' + Name
WHERE     (IndentLevel = 1 and taskid=0)

UPDATE    dbo.TaskEstimaterNew
SET              Name = '            ' + Name
WHERE     (IndentLevel = 2 and taskid=0)

UPDATE    Task
SET          StatusID = e.StatusID, EstDuration=e.EstDuration, EstCost=e.EstCost, Name=e.Name, Description=e.Description,
	     Notes=e.Notes, DeadLine=e.DeadLine, TaskTypeID=e.TaskTypeID,ProjectTypeID=e.ProjectTypeID,Structure=e.Structure
FROM         Task t, TaskEstimaterNew e
WHERE    ( t .TaskID = e.TaskID) and (e.StatusID=5) --added on 4/12/06

--=======================================
DECLARE TaskEstimaterNew_Cursor CURSOR FOR
SELECT    TaskEstimaterNewID,  Taskid, viewOrder 
FROM      dbo.TaskEstimaterNew
ORDER BY ViewOrder

OPEN TaskEstimaterNew_Cursor
FETCH TaskEstimaterNew_Cursor INTO @TaskEstimaterNewID, @taskid, @vieworder 
WHILE @@Fetch_Status = 0
   BEGIN

	if(@taskid=0)
	begin
		set @myVieworder=(select vieworder from task where taskid=@ptaskid)
	--update the task's vieworder after the parent
	update dbo.task set vieworder=vieworder+1
		where vieworder>(@myVieworder+@newRowCount)

	set @newRowCount=@newRowCount+1
	--update the vieworder in the TaskEstimaterNew
	UPDATE    dbo.TaskEstimaterNew
	SET       ViewOrder = (@myVieworder + @newRowCount)
	WHERE   TaskEstimaterNewID=@TaskEstimaterNewID--  vieworder = @vieworder

	--=========added on 1/19/06 to update the history tabl
	set @maxTaskid =( SELECT    MAX(TaskID) AS taskid
		FROM         dbo.Task)
	--==============================
	--now insert the new row to the task table
	INSERT INTO dbo.Task
                      (ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI)
	SELECT     ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI
	FROM         dbo.TaskEstimaterNew
	where    TaskEstimaterNewID=@TaskEstimaterNewID and (StatusID=5) --added on 4/12/06

	
	set @parentid=(select ParentTaskID from task where taskid=@pTaskid)
	
	update task set ParentTaskID = @parentid
		WHERE  (vieworder=@myVieworder+@newRowCount)

	--=========added on 1/19/06 to update the history tabl
	INSERT INTO dbo.TaskHistory
		SELECT  distinct   t.TaskID, t.StatusID, e.inUse AS changedby, GETDATE() AS changedDate
		FROM         dbo.Task t, TaskEstimaterNew e
		WHERE     (t.TaskID > @maxTaskid) and (e.StatusID=5) --added on 4/12/06

	--==============================================
	end--end of if(@taskid=0)
	else--if(taskid!=0)
	begin
		--=========added on 1/19/06 to update the history tabl
		INSERT INTO dbo.TaskHistory
		SELECT  distinct   t.TaskID, t.StatusID, e.inUse AS changedby, GETDATE() AS changedDate
		FROM         dbo.Task t, TaskEstimaterNew e
		WHERE     (t.TaskID = @Taskid) and (e.StatusID=5) --added on 4/12/06

		set @ptaskid=@taskid
		set @newRowCount=0
	end

     FETCH TaskEstimaterNew_Cursor INTO @TaskEstimaterNewID, @taskid, @vieworder  
   END
	--==============================

CLOSE TaskEstimaterNew_Cursor
DEALLOCATE TaskEstimaterNew_Cursor

--==========added on 2/14/06 to fix kevin's name
UPDATE    dbo.TaskHistory
SET              ChangedBy = 'KFargason'
WHERE     (ChangedBy = 'KFargaso')


update dbo.task set inuse=null
where inuse is not null
