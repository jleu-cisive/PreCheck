-- =============================================
-- Author: Radhika Dereddy
-- Create date: 07/27/2021
-- Description:	New QReport for ReferenceVerificationReceived
-- Modify By Radhika Dereddy on 07/26/2021 for dates to be considered appropriately.
-- EXEC [QReport_ReferenceVerificationReceived]'07/23/2021','07/23/2021'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ReferenceVerificationReceived]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


IF OBJECT_ID('tempdb..#ReferenceVerificationTempTable ') IS NOT NULL
	Drop Table #ReferenceVerificationTempTable 

SELECT p.Apno INTO #ReferenceVerificationTempTable
FROM dbo.precheckservicelog p WITH (NOLOCK) 
WHERE p.request.exist('declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:PersonalReferences/a:PersonalReference/a:SectStat = ''9'' and
/m:UpsertRequest/a:ApplicationSectionOption/a:IncludePersonalReference = ''true''' ) = 1 
and p.ServiceName = 'ApplicantService.UpsertApplication' 
AND p.ServiceDate >= @StartDate AND p.ServiceDate < DateAdd(day, 1, @EndDate)


SELECT COUNT(DISTINCT e.PersRefID) as 'PersonalReference Received' FROM PersRef e 
INNER JOIN #ReferenceVerificationTempTable ta on e.APNO = ta.apno  
WHERE IsOnReport = 1


IF OBJECT_ID('tempdb..#ReferenceVerificationTempTable ') IS NOT NULL
	Drop Table #ReferenceVerificationTempTable

END
