

CREATE PROCEDURE [dbo].[TaskQueueToTaskold] AS

DECLARE  @taskid  int, @ptaskid int, @vieworder int, @myParentID int, @statusViewOrder int
DECLARE  @myIndent int, @nextIndent int, @newStautsid int
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
	end

	--update the task's vieworder after the parent
	update dbo.task set vieworder=vieworder+1
		where vieworder>@vieworder


                
	Set @myParentID = (SELECT ParentTaskID
		FROM       dbo.Task 
		where      TaskID=@ptaskid)


	--get the @myParentID from the task
	while (SELECT ParentTaskID
		FROM       dbo.Task 
		where      TaskID=@ptaskid) <>0
	begin
       	   set  @statusViewOrder =  (SELECT     refTaskStatus.DisplayOrder
		FROM  refTaskStatus INNER JOIN
                      Task ON refTaskStatus.refTaskStatusID = Task.StatusID
		WHERE Task.TaskID = @myParentID) 



	 	 if(@statusViewOrder>9)
	  	 begin
			set @newStautsid=(SELECT  refTaskStatus.refTaskStatusID
		 	FROM   refTaskStatus 
			WHERE  refTaskStatus.DisplayOrder = @statusViewOrder)



			update task set statusid = @newStautsid
			WHERE  task.taskid=@myParentID
		end	



		set @ptaskid=(SELECT ParentTaskID
			FROM       dbo.Task 
			where      TaskID=@ptaskid)	



		if(@ptaskid=0)
		break
	end
	
	--now update the grand parent's status
	set  @statusViewOrder =  (SELECT     refTaskStatus.DisplayOrder
		FROM  refTaskStatus INNER JOIN
                      Task ON refTaskStatus.refTaskStatusID = Task.StatusID
		WHERE Task.TaskID = @ptaskid) 

	--print "statusvobf "+CONVERT(nvarchar, @statusViewOrder)

	 	 if(@statusViewOrder>9)
	  	 begin
			update task set statusid=(SELECT  refTaskStatus.refTaskStatusID
		 	FROM   refTaskStatus INNER JOIN
         	              Task ON refTaskStatus.refTaskStatusID = Task.StatusID
			WHERE  (refTaskStatus.DisplayOrder = @statusViewOrder and task.taskid=@ptaskid) )

		end
	--now insert the bug row to the task table
	INSERT INTO dbo.Task
                      (ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI)
	SELECT     ExpandCollapse, IsHidden, Name, DetailPriority, Description, Notes, DeadLine, DeadLineMet, BugCountQA, BugCountClient, EstDuration, TimeToEst, 
                      ActDuration, CollectivePriority, Priority, ViewOrder, IndentLevel, ParentTaskID, DeveloperID, StatusID, TaskTypeID, IsLowestDisplayLevel, 
                      isReportLevel, inUse, Structure, ProjectTypeID, Client, EstCost, EstReturn, ROI
	FROM         dbo.TaskQueue
	where    taskqueueid=@taskid


     FETCH taskqueue_Cursor INTO @taskid,@ptaskid--, @vieworder 
   END
CLOSE taskqueue_Cursor
DEALLOCATE taskqueue_Cursor

update dbo.task set inuse=null
where inuse is not null
