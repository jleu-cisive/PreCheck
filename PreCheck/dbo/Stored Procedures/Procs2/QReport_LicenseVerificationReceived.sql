
-- =============================================
-- Author: Radhika Dereddy
-- Create date: 07/27/2021
-- Description:	New QReport for LicenseVerificationReceived
-- Modify By Radhika Dereddy on 07/26/2021 for dates to be considered appropriately.
-- EXEC [QReport_LicenseVerificationReceived]'07/23/2021','07/26/2021'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_LicenseVerificationReceived]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


drop table if exists #LicenseVerificationTempTable 
drop table if exists #firstselect

--declare @StartDate datetime = '07/26/2021'
--declare @EndDate datetime = '07/26/2021'


SELECT Apno INTO #firstselect
FROM precheckservicelog WITH (NOLOCK) 
WHERE ServiceName = 'ApplicantService.UpsertApplication' 
AND ServiceDate >= @StartDate 
AND ServiceDate < DateAdd(day, 1, @EndDate)

SELECT f.Apno 
INTO #LicenseVerificationTempTable
FROM #firstselect f
JOIN [dbo].[PrecheckServiceLog] p on p.apno = f.apno
WHERE request.exist('declare namespace a="http://schemas.datacontract.org/2004/07/PreCheckBPMServiceHelper"; 
declare namespace i="http://www.w3.org/2001/XMLSchema-instance"; 
declare namespace m="http://schemas.datacontract.org/2004/07/PreCheck.Services.WCF.DataContracts"; 
/m:UpsertRequest/m:Application/a:NewApplicants/a:NewApplicant/a:Licenses/a:License/a:SectStat = ''9'' and
/m:UpsertRequest/a:ApplicationSectionOption/a:IncludeLicense = ''true''' ) = 1 


SELECT COUNT(DISTINCT e.ProfLicID) as 'License Received' FROM ProfLic e 
INNER JOIN #LicenseVerificationTempTable ta on e.APNO = ta.apno  
WHERE IsOnReport = 1


END
