-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 03/20/2018
-- Description:	 (Requester - Dana Sangerhausen) Objective is to understand when the actual verification itself is distributed to the group (date and time stamp). 
-- In some cases it will be after the AI has finalized review in others it will be when a CAM adds the item.  
-- Should be measured by time that the license verification is placed in Pending in the report.
-- Modified By:Amy Liu on 08/21/2018:HDT 37978
---HDT37978:split date and time into two separate columns Also, for time, please adjust to 24 hour clock so that we can tell 6 am from 6 pm (18:00).
-- EXEC [dbo].[License_Verifications_Received_Detail] '08/01/2018','08/05/2018'
-- Modified BY Prasanna Kumari on 10/05/2018
-- Added a new column for Licnese Number per applicant - per Dana
-- =============================================
CREATE PROCEDURE [dbo].[License_Verifications_Received_Detail] 
@StartDate DateTime,
@EndDate DateTime

AS

IF OBJECT_ID('tempdb..#LicenseVerificationTempTable') IS NOT NULL
    DROP TABLE #LicenseVerificationTempTable

SELECT distinct l.apno ReportNumber, a.CreatedDate ReportCreatedDate,o.AIMICreatedDate DateLicenseReceived, c.name clientName, e.Lic_type LicenseType, e.State LicenseState, e.Lic_No AS LicenseNumber
INTO #LicenseVerificationTempTable
FROM precheckservicelog l WITH (NOLOCK) 
INNER JOIN appl a WITH (nolock) ON a.apno = l.apno
inner join ProfLic e with (nolock) on e.apno = l.apno
inner join client c with (nolock) on c.clno = l.clientID
INNER JOIN [Metastorm9_2].dbo.Oasis o with(nolock) ON o.apno= a.apno
WHERE request.value(
'declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
(/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Licenses/a:License/a:SectStat)[1]', 'int') like '%9%' 
AND l.ServiceDate >= @StartDate AND l.ServiceDate <= DateAdd(day, 1, @EndDate)
and e.isOnReport=1
Order BY a.CreatedDate DESC 


SELECT v.ReportNumber, v.LicenseNumber, Format(v.ReportCreatedDate, 'MM/dd/yyyy HH:mm:ss') ReportCreatedDate, 
Format(v.DateLicenseReceived, 'MM/dd/yyyy') DateLicenseReceived, 
Format(v.DateLicenseReceived, 'HH:mm:ss') TimeLicenseReceived, 
v.clientName ClientName, v.LicenseType, v.LicenseState 
From #LicenseVerificationTempTable v
WHERE v.DateLicenseReceived IS NOT null

IF OBJECT_ID('tempdb..#LicenseVerificationTempTable') IS NOT NULL
    DROP TABLE #LicenseVerificationTempTable
