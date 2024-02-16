CREATE PROCEDURE [dbo].[FormTaskHistoryGetTime] 

( 
	@statusID int, 
	@taskID int
)
AS

	/*SET NOCOUNT ON;*/
SELECT     ChangedDate
FROM         dbo.TaskHistory
WHERE     (NewTaskStatusID = @statusID) AND (TaskID = @taskID)