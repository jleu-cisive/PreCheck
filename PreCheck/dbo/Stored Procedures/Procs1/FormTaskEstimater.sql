﻿
CREATE PROCEDURE dbo.FormTaskEstimater @UserID varchar(8) AS

DECLARE @InUse varchar(8)

	
	SELECT Top 1 @InUse=InUse FROM Task WHERE InUse is not null

	if(@InUse is null)
	BEGIN
		exec InUseTaskSet_NoCheck @UserID
		exec UpdateTaskEstimater     
              
		select taskid from taskestimaternew where statusid=5
		--DELETE FROM dbo.TaskEstimaterNew
		--exec InUseTaskClear
	END
