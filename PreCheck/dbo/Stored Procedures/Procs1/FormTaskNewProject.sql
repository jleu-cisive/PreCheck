
CREATE PROCEDURE [dbo].[FormTaskNewProject]   AS

SET NOCOUNT ON
DECLARE  @taskid  int, @parentid int, @vieworder int, @maxPriority int, @maxTaskid int

--=============get the viewOrder and priority first
 SELECT  @maxPriority=   MAX(DetailPriority)
         	 FROM      dbo.Task
         	 WHERE    (IndentLevel = 0 AND DetailPriority < 1000)

set @parentid=(select taskid from task where detailpriority=@maxPriority)

SET @vieworder=--(SELECT    ViewOrder
         	 --FROM     dbo.Task
         	 --WHERE    IndentLevel = 0 AND DetailPriority = @maxPriority )-1

		(SELECT     MAX(ViewOrder)
		FROM         dbo.Task
		WHERE     (ParentTaskID = @parentid))

if(@vieworder=null)
  set @vieworder=(select vieworder from task where taskid=@parentid)

set @parentid=0

--=======================================
--update the indentLevel now

UPDATE    dbo.TaskQueueNew
SET     IndentLevel = 0,  ExpandCollapse = '-', IsHidden = 0, ParentTaskID = 0, 
	isReportLevel = '*', EstDuration=0, IsLowestDisplayLevel=0, Priority=0,DetailPriority=0,
	BugCountQA=0, BugCountClient=0, TimeToEst=0,ActDuration=0,CollectivePriority=0,
	EstCost=0, ROI=0
WHERE     (TaskTypeID = 1)

UPDATE    dbo.TaskQueueNew
SET     IndentLevel = 1,  ExpandCollapse = ' ', IsHidden = 0, ParentTaskID = 0, 
	isReportLevel = ' ', EstDuration=0, IsLowestDisplayLevel=0, Priority=0,DetailPriority=0,
	BugCountQA=0, BugCountClient=0, TimeToEst=0,ActDuration=0,CollectivePriority=0,
	EstCost=0,EstReturn=0,ROI=0
WHERE     (TaskTypeID = 2)

UPDATE    dbo.TaskQueueNew
SET              Name = '      ' + Name
WHERE     (IndentLevel = 1)
--========added on 2/20/06 to prevent bad data
UPDATE    dbo.TaskQueueNew
SET     StatusID = 4,  ExpandCollapse = ' ', IsHidden = 0, ParentTaskID = 0, DeadLine=null, Client=null, ProjectTypeID=1, 
	isReportLevel = ' ', EstDuration=0, IsLowestDisplayLevel=0, Priority=0,DetailPriority=0,
	BugCountQA=0, BugCountClient=0, TimeToEst=0,ActDuration=0,CollectivePriority=0,
	EstCost=0,EstReturn=0,ROI=0
WHERE     (StatusID is null)
--===================================
--=======================================
DECLARE TaskQueueNew_Cursor CURSOR FOR
SELECT    TaskQueueNewid 
FROM      dbo.TaskQueueNew

OPEN TaskQueueNew_Cursor
FETCH TaskQueueNew_Cursor INTO @taskid 
WHILE @@Fetch_Status = 0
   BEGIN

	--update the vieworder in the TaskQueueNew
	UPDATE    dbo.TaskQueueNew
	SET       ViewOrder =@vieworder + 1
	WHERE     (TaskQueueNewID = @taskid)
	--now update the detailpriority if it's a parent
	UPDATE    dbo.TaskQueueNew
	SET       DetailPriority =@maxPriority + 1,  CollectivePriority =@maxPriority+1
	WHERE     (TaskQueueNewID = @taskid and indentlevel=0)

	--hz added on 4/17/06
	UPDATE    dbo.TaskQueueNew
	SET       CollectivePriority =@maxPriority
	WHERE     (TaskQueueNewID = @taskid and indentlevel>0)

	
	--update the task's vieworder after the parent
	update dbo.task set vieworder=vieworder+1
		where vieworder>@vieworder

	--=========added on 1/19/06 to update the history tabl
	set @maxTaskid =( SELECT    MAX(TaskID) AS taskid
		FROM         dbo.Task)
	--==============================
	--now insert the new row to the task table
	INSERT INTO dbo.Task
                      (ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI, PriorityLevelID)
	SELECT     ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI, PriorityLevelID
	FROM         dbo.TaskQueueNew
	where    vieworder=@vieworder

	
	set @parentid=(select max(taskid) from task where indentlevel=0)
	
	update task set ParentTaskID = @parentid
		WHERE  (vieworder=@vieworder and indentlevel=1)

	set @vieworder=@vieworder+1
	if((select indentlevel from TaskQueueNew WHERE TaskQueueNewID = @taskid )=0)
	begin
		set @maxPriority=@maxPriority+1
	end

	--=========added on 1/19/06 to update the history tabl
	INSERT INTO dbo.TaskHistory
		SELECT     TaskID, StatusID, inUse AS changedby, GETDATE() AS changedDate
		FROM         dbo.Task
		WHERE     (TaskID > @maxTaskid)

	--==============================================
     FETCH TaskQueueNew_Cursor INTO @taskid 
   END

	--=========added on 1/19/06 to update the history tabl
	set @maxTaskid =( SELECT    MAX(TaskID) AS taskid
		FROM         dbo.Task)
	--==============================
--now insert the new row to the task table
	INSERT INTO dbo.Task
                      (ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI, PriorityLevelID)
	SELECT     ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI, PriorityLevelID
	FROM         dbo.TaskQueueNew
	where    vieworder=@vieworder

	update task set ParentTaskID = @parentid
	WHERE  (vieworder=@vieworder and indentlevel=1)
	--=========added on 1/19/06 to update the history tabl
	INSERT INTO dbo.TaskHistory
		SELECT     TaskID, StatusID, inUse AS changedby, GETDATE() AS changedDate
		FROM         dbo.Task
		WHERE     (TaskID > @maxTaskid)

	--==============================================

CLOSE TaskQueueNew_Cursor
DEALLOCATE TaskQueueNew_Cursor

--==========added on 2/14/06 to fix kevin's name
UPDATE    dbo.TaskHistory
SET              ChangedBy = 'KFargason'
WHERE     (ChangedBy = 'KFargaso')


update dbo.task set inuse=null
where inuse is not null
