
--MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM

CREATE PROCEDURE [dbo].[FormTaskEstimaterDel] AS

DELETE FROM dbo.TaskEstimaterNew
DELETE FROM dbo.TaskEstimaterTemp
--WHERE     (StatusID = 5)

		exec InUseTaskClear