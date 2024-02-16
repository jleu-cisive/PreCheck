
--**********************************************

CREATE PROCEDURE dbo.WinSvc_InsertLog
(@logMessage text)
AS
SET NOCOUNT ON

INSERT INTO dbo.WinServiceLog
SELECT getdate(), @logMessage

SET NOCOUNT OFF

