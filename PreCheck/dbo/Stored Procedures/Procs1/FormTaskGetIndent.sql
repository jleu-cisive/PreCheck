





CREATE PROCEDURE [dbo].[FormTaskGetIndent]  @taskID int AS


SELECT     IndentLevel, DeveloperID
FROM         dbo.Task
WHERE     (TaskID = @taskID)

