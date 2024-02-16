
CREATE  PROCEDURE dbo.TaskQueueNewProj @UserID varchar(12), @EstReturn int, @Plevel int  AS

set nocount on
DECLARE @InUse varchar(12),  @maxTaskid int, @newRows int

	exec FormTaskNewProjPriorityLevelUpdate @Plevel, @EstReturn
	
	SELECT Top 1 @InUse=InUse FROM Task WHERE InUse is not null

	if(@InUse is null)
	BEGIN
		exec InUseTaskSet_NoCheck @UserID
		exec FormTaskNewProject  
              
		--added on 2/15/06 for email part
		set @maxTaskid=(select max(taskid) as taskid from task)
		set @newRows=(select count(*) as rcount from taskqueuenew)
		SELECT     TaskID, Name
		FROM         dbo.Task
		WHERE     (TaskID > (@maxTaskid - @newRows))

		--DELETE FROM dbo.TaskQueueNew
		--exec InUseTaskClear
	END