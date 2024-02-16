-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 03/20/2018
-- Description:	 (Requester - Dana Sangerhausen) Objective is to understand when the actual verification itself is distributed to the group (date and time stamp).  
-- In some cases it will be after the AI has finalized review in others it will be when a CAM adds the item.  
-- Should be measured by time that the education verification is placed in Pending in the report. 
-- Modified By:Prasanna on 08/22/2018:HDT 37977 - split date and time into two separate columns and adjust to 24 hour clock
--EXEC [Education_Verifications_Received_Detail] '07/01/2018', '08/01/2018'
-- =============================================
CREATE PROCEDURE [dbo].[Education_Verifications_Received_Detail] 
@StartDate DateTime,
@EndDate DateTime

AS

IF OBJECT_ID('tempdb..#EducationVerificationTempTable') IS NOT NULL
    DROP TABLE #EducationVerificationTempTable

SELECT distinct l.apno ReportNumber, a.CreatedDate ReportCreatedDate,o.AIMICreatedDate DateEducationReceived, c.name clientName, e.School InstitutionName
INTO #EducationVerificationTempTable
FROM precheckservicelog l WITH (NOLOCK) 
INNER JOIN appl a WITH (nolock) ON a.apno = l.apno
inner join Educat e with (nolock) on e.apno = l.apno
inner join client c with (nolock) on c.clno = l.clientID
INNER JOIN [Metastorm9_2].dbo.Oasis o with(nolock) ON o.apno= a.apno
WHERE request.value(
'declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
(/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Educations/a:Education/a:SectStat)[1]', 'int') like '%9%' 
AND l.ServiceDate >= @StartDate AND l.ServiceDate <= DateAdd(day, 1, @EndDate)
and e.isOnReport=1
--AND o.AIMICreatedDate IS NOT NULL
Order BY a.CreatedDate DESC 


SELECT v.ReportNumber, Format(v.ReportCreatedDate, 'MM/dd/yyyy HH:mm:ss') ReportCreatedDate, Format(v.DateEducationReceived, 
'MM/dd/yyyy') DateEducationReceived, Format(v.DateEducationReceived, 'HH:mm:ss') TimeEducationReceived, v.clientName ClientName, v.InstitutionName 
From #EducationVerificationTempTable v
WHERE v.DateEducationReceived IS NOT null

IF OBJECT_ID('tempdb..#EducationVerificationTempTable') IS NOT NULL
    DROP TABLE #EducationVerificationTempTable
