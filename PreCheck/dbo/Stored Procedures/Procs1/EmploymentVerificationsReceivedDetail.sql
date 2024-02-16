---*************************************************************************
---Created by Amy Liu on 03/12/2018 HDT30425	
-- EXEC [dbo].[EmploymentVerificationsReceivedDetail] '07/01/2021','07/01/2021'
--Modified by - Radhika Dereddy
--Modified Date - 04/02/2018
-- Reason - Add a new column for Affiliate and affiliateID
--modified by Amy Liu on 04/02/2018 to add Initial Investigator Assigned and Investigator Assigned at Closure (meaning once the Sect Status went from Pending to any other Status other than Needs Review or Pending)
--Modified by Prasanna on 08/09/2018 added new column Client Type
---*************************************************************************
CREATE PROCEDURE [dbo].[EmploymentVerificationsReceivedDetail] 
@FromDate DateTime,
@ToDate DateTime

AS

IF OBJECT_ID('tempdb..#tempVerificationTable') IS NOT NULL
    DROP TABLE #tempVerificationTable

CREATE TABLE #tempVerificationTable  
(  
    --SectionId int 
	Apno int
)  
INSERT INTO #tempVerificationTable

SELECT Apno
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
AND ServiceDate > @FromDate AND ServiceDate < DateAdd(day, 1, @ToDate)


SELECT distinct e.EmplID, e.APNO, e.Employer EmployerName, e.Investigator, e.InvestigatorAssigned, e.createdDate DateEmploymentReceived
FROM Empl e with(nolock)
INNER JOIN #tempVerificationTable ta on e.APNO = ta.apno 
--INNER JOIN [Metastorm9_2].dbo.Oasis o with(nolock) ON o.apno= e.apno 
WHERE IsOnReport = 1

/*
--INSERT INTO #VerificationTempTable
SELECT DISTINCT e.EmplID, l.apno ReportNumber, a.ApDate ReportCreatedDate,
			o.AIMICreatedDate DateEmploymentReceived,e.Investigator, e.InvestigatorAssigned,
			c.name clientName, e.employer EmployerName, rf.Affiliate, rf.AffiliateID, rct.ClientType 
INTO #TempVerificationTable
FROM PrecheckServicelog l WITH (NOLOCK) 
INNER JOIN appl a WITH (nolock) ON a.apno = l.apno
INNER JOIN empl e with (nolock) on e.apno = l.apno
INNER JOIN client c with (nolock) on a.CLNO  = c.clno  
INNER JOIN refclientType rct with (nolock) on c.ClientTypeID = rct.ClientTypeID
INNER JOIN refAffiliate rf with(nolock) on C.AffiliateID = rf.AffiliateID 
INNER JOIN [Metastorm9_2].dbo.Oasis o with(nolock) ON o.apno= e.apno
WHERE request.exist(
		'declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
		declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
		declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
		/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Employments/a:Employment/a:SectStat = ''9'' and
		/m:UpsertRequest/a:ApplicationSectionOption/a:IncludeEmployment = ''true''' ) =1
AND serviceName = 'ApplicantService.UpsertApplication' 
AND l.ServiceDate > @FromDate AND l.ServiceDate < DateAdd(day, 1, @ToDate)
and e.isOnReport = 1 
Order BY a.ApDate DESC 

SELECT v.ReportNumber, 
	FORMAT(v.ReportCreatedDate, 'MM/dd/yyyy HH:mm:ss') ReportCreatedDate, 
	FORMAT(v.DateEmploymentReceived, 'MM/dd/yyyy HH:mm:ss') DateEmploymentReceived, 
	v.Investigator, 
	v.InvestigatorAssigned, 
	--lg.ChangeDate AS InvestigatorClosure , 
--	lg.UserID,	
	v.clientName ClientName,
	v.EmployerName,
	v.Affiliate,
	v.AffiliateID,
	v.ClientType
FROM #TempVerificationTable v
--LEFT JOIN  [PreCheck].[dbo].[ChangeLog] lg with(nolock) on v.EmplID	= lg.ID 
--														AND  lg.tablename = 'Empl.SectStat' 
--														AND lg.OldValue='9' AND lg.NewValue<>'9'
WHERE v.DateEmploymentReceived IS NOT null


IF OBJECT_ID('tempdb..#VerificationTempTable') IS NOT NULL
    DROP TABLE #VerificationTempTable

*/