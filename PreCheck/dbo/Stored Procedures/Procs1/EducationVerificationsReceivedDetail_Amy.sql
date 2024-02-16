---*************************************************************************
---Created by Amy Liu on 03/12/2018 HDT30425	
--   [dbo].[EducationVerificationsReceivedDetail_Amy] '10/03/2017', '10/03/2017'
---*************************************************************************
CREATE PROCEDURE [dbo].[EducationVerificationsReceivedDetail_Amy] 
@FromDate DateTime,
@ToDate DateTime

AS

IF OBJECT_ID('tempdb..#VerificationTempTable') IS NOT NULL
    DROP TABLE #VerificationTempTable

SELECT l.apno ReportNumber, a.CreatedDate ReportCreatedDate,e.web_updated DateEmploymentReceived,c.name clientName, e.School SchoolName
INTO #VerificationTempTable
FROM precheckservicelog l WITH (NOLOCK) 
INNER JOIN appl a WITH (nolock) ON a.apno= l.apno
inner join [dbo].[Educat] e with (nolock) on e.apno=l.apno
inner join client c with (nolock) on c.clno = l.clientID
WHERE request.value(
'declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
(/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Employments/a:Employment/a:SectStat)[1]', 'int') like '%9%' --like '%9%' --order by 1 desc
AND l.ServiceDate > @FromDate AND l.ServiceDate < DateAdd(day, 1, @ToDate)
and e.isOnReport=1
Order by l.serviceDate desc


SELECT * From #VerificationTempTable

IF OBJECT_ID('tempdb..#VerificationTempTable') IS NOT NULL
    DROP TABLE #VerificationTempTable
