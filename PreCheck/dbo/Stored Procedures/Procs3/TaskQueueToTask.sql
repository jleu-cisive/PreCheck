

CREATE   PROCEDURE [dbo].[TaskQueueToTask] AS

DECLARE  @taskid  int, @ptaskid int, @vieworder int, @myParentID int, @statusViewOrder int
DECLARE  @myIndent int, @nextIndent int, @newStatusid int, @vieworder2 int, @maxTaskid int
DECLARE taskqueue_Cursor CURSOR FOR
SELECT    taskqueueid, parenttaskid--, vieworder 
FROM      dbo.taskqueue 

OPEN taskqueue_Cursor
FETCH taskqueue_Cursor INTO @taskid,@ptaskid--, @vieworder 
WHILE @@Fetch_Status = 0
   BEGIN
--print @ptaskid
	--first update the taskqueue's vieworder & indent based on task
    	update  dbo.taskqueue  
   	set ViewOrder = (SELECT     ViewOrder
		FROM       dbo.Task 
		where      TaskID=@ptaskid) + 1, 
	    IndentLevel =
               (SELECT     IndentLevel
		FROM       dbo.Task 
		where      TaskID=@ptaskid) + 1
                 where taskqueueid=@taskid

	--get the vieworder of the parent from the task
	SELECT @vieworder= ViewOrder
		FROM       dbo.Task 
		where      TaskID=@ptaskid
	--get the next row's indentlevel
	SELECT @nextIndent= IndentLevel
		FROM       dbo.Task 
		where      vieworder=@vieworder+1
	--get current row's indent 
	SELECT @myIndent= IndentLevel
		FROM       dbo.Taskqueue
		where 	   taskqueueid=@taskid
	
	--if nextindent < myIndent then it's a only child; need update the parent's status to 10
	if(@nextIndent < @myIndent)
	begin
		update task set statusid = 10
			WHERE  task.taskid=@ptaskid

		UPDATE    dbo.Task
		SET              ExpandCollapse = '-'
		WHERE     (TaskID = @ptaskid)
		
		--~~~~~~~~~~~~~~hz added on 5/15/06 
	
		if (select BugCountClient from taskqueue)=1
		begin
			UPDATE    dbo.Task
			SET       BugCountClient = 1
			WHERE     (TaskID = @ptaskid)
		end
		else
		begin
			UPDATE    dbo.Task
			SET       BugCountQA = 1
			WHERE     (TaskID = @ptaskid)
		end
	
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	end
	else if(@nextIndent = @myIndent)
	begin
		
		UPDATE    dbo.Task
		SET  BugCountClient = BugCountClient+1,
		     BugCountQA = BugCountQA+1
		where taskid=@ptaskid
	end
	

	--update the task's vieworder after the parent
	update dbo.task set vieworder=vieworder+1
		where vieworder>@vieworder

	--get the @myParentID from the task
	while (SELECT ParentTaskID
		FROM       dbo.Task 
		where      TaskID=@ptaskid) <>0
	begin
       	   set  @statusViewOrder =  (SELECT     MIN(refTaskStatus.DisplayOrder) AS pStatus
		FROM         refTaskStatus INNER JOIN
                      			Task ON refTaskStatus.refTaskStatusID = Task.StatusID
		WHERE     Task.ParentTaskID = @ptaskid)

			set @newStatusid=(SELECT  refTaskStatus.refTaskStatusID
		 	FROM   refTaskStatus 
			WHERE  refTaskStatus.DisplayOrder = @statusViewOrder)



			update task set statusid = @newStatusid
			WHERE  task.taskid=@myParentID

		--~~~~~~~~~~~~~~hz added on 5/15/06 
	UPDATE    dbo.Task
	SET              BugCountClient =
                          (SELECT     SUM(BugCountClient) AS ccnt
                            FROM          dbo.Task
                            WHERE      (ParentTaskID = @myParentID)), 
		 BugCountQA =
                          (SELECT     SUM(BugCountQA) AS qcnt
                            FROM          dbo.Task
                            WHERE      (ParentTaskID = @myParentID))
	where taskid=@myParentID
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		set @ptaskid=(SELECT ParentTaskID
			FROM       dbo.Task 
			where      TaskID=@ptaskid)	

		

		if(@ptaskid=0)
		break
	end
	
	
	--now update the grand parent's status
	set  @statusViewOrder =  (SELECT  min(   refTaskStatus.DisplayOrder)
		FROM  refTaskStatus INNER JOIN
                      Task ON refTaskStatus.refTaskStatusID = Task.StatusID
		WHERE Task.ParentTaskID = @ptaskid) 

	set @newStatusid=(SELECT  refTaskStatus.refTaskStatusID
		 	FROM   refTaskStatus 
			WHERE  refTaskStatus.DisplayOrder = @statusViewOrder)

	--print "statusvobf "+CONVERT(nvarchar, @statusViewOrder)

			update task set statusid=@newStatusid
			WHERE  taskid=@ptaskid

	--~~~~~~~~~~~~~~hz added on 5/15/06 
	UPDATE    dbo.Task
	SET       BugCountClient =
                          (SELECT     SUM(BugCountClient) AS ccnt
                            FROM          dbo.Task
                            WHERE      (ParentTaskID = @ptaskid)), 
		 BugCountQA =
                          (SELECT     SUM(BugCountQA) AS qcnt
                            FROM          dbo.Task
                            WHERE      (ParentTaskID = @ptaskid))
	where taskid=@ptaskid
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--=========added on 1/19/06 to update the history tabl
	set @maxTaskid =( SELECT    MAX(TaskID) AS taskid
		FROM         dbo.Task)
	--==============================
	--now insert the bug row to the task table
	INSERT INTO dbo.Task
                      (ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI)
	SELECT     ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI
	FROM         dbo.TaskQueue
	where    taskqueueid=@taskid and vieworder!=null

	
	UPDATE    dbo.Task
	SET       BugCountClient =
                          (SELECT     SUM(BugCountClient) AS ccnt
                            FROM          dbo.Task
                            WHERE      (ParentTaskID = @ptaskid)), 
		 BugCountQA =
                          (SELECT     SUM(BugCountQA) AS qcnt
                            FROM          dbo.Task
                            WHERE      (ParentTaskID = @ptaskid))
	where taskid=@ptaskid
	
	--=========added on 1/19/06 to update the history tabl
	INSERT INTO dbo.TaskHistory
		SELECT     TaskID, StatusID, inUse AS changedby, GETDATE() AS changedDate
		FROM         dbo.Task
		WHERE     (TaskID > @maxTaskid)

	--==============================================
     FETCH taskqueue_Cursor INTO @taskid,@ptaskid--, @vieworder 
   END
CLOSE taskqueue_Cursor
DEALLOCATE taskqueue_Cursor

--==========added on 2/14/06 to fix kevin's name
UPDATE    dbo.TaskHistory
SET              ChangedBy = 'KFargason'
WHERE     (ChangedBy = 'KFargaso')

update dbo.task set inuse=null
where inuse is not null
