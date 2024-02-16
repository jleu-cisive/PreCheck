-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/06/2021
-- Description:	Licenses For Automated Agent Processing
-- EXEC [LicensesForAutomatedAgentProcessing] 
-- =============================================
CREATE PROCEDURE [dbo].[LicensesForAutomatedAgentProcessing]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @LicenseCount int;
DECLARE @LicenseType varchar(50);
DECLARE @LicenseTypeCount int

DROP TABLE IF EXISTS #tempResultMapping


DECLARE @LastSuccessfulRun DATETIME
--SELECT @LastSuccessfulRun = MAX(ISNULL(DateStamp, '01/01/2021')) FROM HEVN..[ClientSchedule_ChangeLog] WITH(NOLOCK) WHERE Succeded = 1 and RecordType ='LicenseAgentAutomation'

SELECT ROW_NUMBER() OVER(ORDER BY SectionKeyId) as ROW_NUM, SectionKeyId 
INTO #tempResultMapping 
FROM Precheck.[dbo].[DataXtract_RequestMapping] 
WHERE Section ='License' and IsBackgroundAutomationEnabled =1
 --AND DataXtract_RequestMappingXMLID in (3635,3741)

SET @LicenseCount = (SELECT count(*) FROM #tempResultMapping);


	WHILE (@LicenseCount <> 0)
	BEGIN

		SET @LicenseType = (SELECT SectionKeyId FROM #tempResultMapping WHERE ROW_NUM = @LicenseCount)
	
		SET @LicenseTypeCount = (SELECT Count(*) FROM dbo.ProfLic pl (NOLOCK) WHERE Ishidden = 0 AND IsOnreport = 1 AND pl.SectStat = '9' 
								AND (pl.Lic_No IS NOT NULL OR LTRIM(RTRIM(pl.Lic_No)) <> '' OR pl.Lic_No NOT IN ('n/a'))
								AND CONCAT(ISNULL(pl.[State],''),'-',ISNULL(pl.Lic_type, '')) = @LicenseType
								AND pl.Is_Investigator_Qualified = 0)

		IF(@LicenseTypeCount > 0)
		BEGIN						 
			SELECT distinct @LicenseType as FileType,
				 'Licensing' as [Section], 
					pl.ProfLicID as [Licenseid],
					a.CLNO as [Employerid],
					REPLACE(c.name,',','') as [EmployerName], 
					'' as [FacilityName],
					pl.Lic_type as [Type],
					'' as [Client License Type],
					pl.[State] as [IssuingState],
					'' as [ExpiresDate],
					REPLACE(a.Last,',','') as [Last],
					REPLACE(a.First,',','') as [first],
					'' as [EmployeeNumber], 
					'' as [DOB],
					REPLACE(pl.Lic_No,',','') as [number],
					a.SSN as [SSN], --full SSN
					REPLACE(a.SSN,'-','') as [SSNNoDashes], -- SSN with no Dashes
					RIGHT(a.SSN,4) as [SSNLast4], --Last 4# SSN
					LEFT(a.SSN,3) as [SSN1], --First 3# of SSN
					(CASE 
						WHEN CHARINDEX('-',a.SSN) > 0 
						THEN SUBSTRING(a.SSN,5,2)
						ELSE SUBSTRING(a.SSN,4,2) 
					END) as [SSN2], --Middle 2# of SSN
					RIGHT(a.SSN,4) [SSN3] -- Last 4# of SSN
			FROM Precheck.dbo.Appl a (NOLOCK)
			INNER JOIN Precheck.dbo.Client C (NOLOCK) ON a.clno = c.clno
			INNER JOIN Precheck.dbo.Proflic pl (NOLOCK) ON a.APNO = pl.Apno 
			INNER JOIN Precheck.dbo.SectStat ss (NOLOCK) ON pl.SectStat = ss.Code
			LEFT join hevn.dbo.vwLicenseTypeAlias LicType on (pl.Lic_Type =LicType.Alias OR Pl.Lic_Type  = LicType.TypeDesc)
			WHERE  pl.Ishidden = 0
			AND pl.IsOnreport = 1 
			AND pl.SectStat = '9'
			--AND a.Apdate >= @LastSuccessfulRun
			AND a.Apdate >= '01/01/2021' 
			AND (pl.Lic_No IS NOT NULL OR LTRIM(RTRIM(pl.Lic_No)) <> '' OR pl.Lic_No NOT IN ('n/a'))
			AND CONCAT(ISNULL(pl.[State],''),'-', ISNULL(LicType.[Type], pl.Lic_Type)) = @LicenseType
			AND pl.Is_Investigator_Qualified = 0
		END
	
	SET @LicenseCount = @LicenseCount - 1

	END

END
