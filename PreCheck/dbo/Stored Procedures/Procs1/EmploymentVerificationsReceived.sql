-- =============================================
-- Author:		Radhika Dereddy
-- Modified date: 07/26/2021
-- Description:	 [EmploymentVerificationsReceived]
--   [dbo].[EmploymentVerificationsReceived] '07/23/2021','07/23/2021'
-- =============================================
CREATE PROCEDURE [dbo].[EmploymentVerificationsReceived]

@StartDate DateTime,
@EndDate Datetime

AS


IF OBJECT_ID('tempdb..#EmploymentVerificationTempTable ') IS NOT NULL
	Drop Table #EmploymentVerificationTempTable 

SELECT Apno INTO #EmploymentVerificationTempTable
FROM precheckservicelog WITH (NOLOCK) 
--WHERE request.value(
--'declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
--declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
--declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
--(/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Employments/a:Employment/a:SectStat)[1]', 'nvarchar') like '%9%' --like '%9%' --order by 1 desc
--AND ServiceDate > @FromDate AND ServiceDate < DateAdd(day, 1, @ToDate)
WHERE request.exist('declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Employments/a:Employment/a:SectStat = ''9'' and
/m:UpsertRequest/a:ApplicationSectionOption/a:IncludeEmployment = ''true''' ) = 1 
and serviceName = 'ApplicantService.UpsertApplication' 
AND ServiceDate >= @StartDate AND ServiceDate < DateAdd(day, 1, @EndDate)


SELECT  count(distinct e.EmplID) 'Employment Received' From Empl e 
inner join #EmploymentVerificationTempTable ta on e.APNO = ta.apno  
WHERE IsOnReport = 1

--SELECT COUNT(distinct EmplId) From Empl WHERE Apno in
--(SELECT Apno From #VerificationTempTable) AND IsOnReport = 1

--IF OBJECT_ID('tempdb..#EmploymentVerificationTempTable ') IS NOT NULL
--	Drop Table #EmploymentVerificationTempTable