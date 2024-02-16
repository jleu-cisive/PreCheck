

-- =============================================
-- Author:		cchaupin
-- Create date: 4-21-09
-- Description:	Main win service schedule pull
-- =============================================
CREATE PROCEDURE [dbo].[WS_CheckActiveService]
	@Server varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT WinServiceScheduleID, ServiceName, ServiceNextRunTime, ServiceType, ServiceTimeValue,
ServiceRetryRunTime, ServiceRetryType, ServiceRetryTimeValue,
 AllowThreading
FROM dbo.WinServiceSchedule WHERE
 ServiceActive = 1 AND ServiceNextRunTime IS NOT NULL
and ServerName = @Server

END


