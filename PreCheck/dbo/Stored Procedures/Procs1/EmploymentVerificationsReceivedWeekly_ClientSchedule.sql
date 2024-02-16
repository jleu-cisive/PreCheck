
-- =============================================
-- Author: Radhika Dereddy
-- Create date: 02/28/2021
-- Description: Mirrored from [EmploymentVerificationsReceived] Qreport
-- EXEC [EmploymentVerificationsReceivedWeekly_ClientSchedule] 
-- =============================================

CREATE PROCEDURE [dbo].[EmploymentVerificationsReceivedWeekly_ClientSchedule]

AS
BEGIN

SET NOCOUNT ON;

DROP TABLE IF EXISTS #VerificationTempTable 

DECLARE @StartDate DATE= DATEADD(DAY, -7 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))  --Weekly Saturday of prior week
DECLARE @EndDate DATE = DATEADD(DAY, -1 - DATEPART(WEEKDAY, GETDATE()), CAST(GETDATE() AS DATE))  --Friday of the next week

CREATE TABLE #VerificationTempTable  
(  
	Apno int
)
  
INSERT INTO #VerificationTempTable

SELECT Apno
FROM precheckservicelog WITH (NOLOCK) 
WHERE request.exist('declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Employments/a:Employment/a:SectStat = ''9'' and
/m:UpsertRequest/a:ApplicationSectionOption/a:IncludeEmployment = ''true''' ) = 1 
and serviceName = 'ApplicantService.UpsertApplication' 
AND ServiceDate > @StartDate AND ServiceDate < DateAdd(day, 1, @EndDate)


SELECT count(distinct e.EmplID) From Empl e WITH(NOLOCK) 
inner join #VerificationTempTable ta on e.APNO = ta.apno  
WHERE IsOnReport = 1

END