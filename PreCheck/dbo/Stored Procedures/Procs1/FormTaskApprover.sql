
CREATE PROCEDURE dbo.FormTaskApprover @UserID varchar(8) AS

DECLARE @InUse varchar(8)

	
	SELECT Top 1 @InUse=InUse FROM Task WHERE InUse is not null

	if(@InUse is null)
	BEGIN
		exec InUseTaskSet_NoCheck @UserID
		exec UpdateTaskApprover    
              
		DELETE FROM dbo.TaskApprover
		exec InUseTaskClear
	END
