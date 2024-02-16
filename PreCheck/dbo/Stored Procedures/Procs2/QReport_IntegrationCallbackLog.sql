
-- =============================================
-- Author:		<Larry Ouch>
-- Create date: <07/29/2021>
-- Description:	Returns Integration Callback Log records
-- for project: SentryMD Integration 
-- exec [dbo].[QReport_IntegrationCallbackLog] @CLNO = 3668, @APNO =NULL, @StartDate='7/21/2021',@EndDate= '7/22/2021'
-- =============================================

CREATE PROCEDURE [dbo].[QReport_IntegrationCallbackLog]
	@CLNO INT,
	@APNO INT,
	@StartDate datetime,
	@EndDate datetime 
AS
BEGIN
	
SET NOCOUNT ON;

--DECLARE @CLNO INT = 3668;
--DECLARE @APNO INT = 5440020;
--DECLARE @StartDate DATETIME ='7/21/2021' ;
--DECLARE @EndDate DATETIME ='7/22/2021' ;

SELECT CallbackLogId, CLNO, APNO, CallbackDate, CallbackPostResult, CallbackCompletedStatus, CallbackPostRequest 
FROM integration_callbacklogging
WHERE
(isnull(nullif(@APNO,''),0)=0 or APNO=@APNO)
AND CALLBACKDATE BETWEEN @STARTDATE AND DATEADD(DAY, 1, @ENDDATE)
AND CLNO = @CLNO
ORDER BY CallbackDate DESC

END
