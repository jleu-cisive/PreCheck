-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/01/2020
-- Description:	Criminal Lead Count by Client Summary
-- EXEC [QReport_CriminalLeadCountbyClientSummary] '16023:16024:16022','06/24/2020','06/24/2020'

-- =============================================
CREATE PROCEDURE [dbo].[QReport_CriminalLeadCountbyClientSummary]
@CLNO VARCHAR(MAX) = NULL,
@StartDate DateTime, 
@EndDate DateTime 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ClientMontlyInfo TABLE
	(
		[Month Order] varchar(20),
		[Client ID] int,
		[Client Name] varchar(100),
		[ReportNumber] int,
		[Applicant Last Name] varchar(50),
		[Applicant First Name] varchar(50),
		[SSN] varchar(11),
		[DOB] varchar(10),
		[Criminal Searches] int,
		[Employment Verifications] int,
		[Education Verifications]int,
		[License Verifications]int,
		[PID]int,
		[SanctionCheck] int,
		[MVR] int,
		[Credit Report] int,
		[Personal References] int,
		[Civil Searches] int,
		[PackageDesc] varchar(100),
		[SelectedPackage] varchar(100),
		[Package] smallmoney,
		[Fees] smallmoney,
		[Crim_Charges] smallmoney,
		[Crim_Service_Charges] smallmoney,
		[Civil_Charges] smallmoney,
		[Social_Charges] smallmoney,
		[Credit_Charges] smallmoney,
		[MVR_Charges] smallmoney,
		[Employment_Charges] smallmoney,
		[Education_Charges] smallmoney,
		[License_Charges] smallmoney,
		[Reference_Charges] smallmoney
	)

	INSERT INTO @ClientMontlyInfo
	EXEC [Client_Monthly_Info] @CLNO, @StartDate, @EndDate


	SELECT [Client ID], CASE WHEN [Client Name]='' THEN 'TOTAL COUNT' ELSE [Client Name] end as [Client Name], 
	--rf.AffiliateID, 
	Sum([Criminal Searches]) as [Total Criminal Leads] 
	FROM @ClientMontlyInfo c
	--INNER JOIN Client cl ON c.[Client ID] = cl.CLNO
	--INNER JOIN RefAffiliate rf ON cl.AffiliateID = rf.AffiliateID
	GROUP BY [Client ID], [Client Name]--, rf.AffiliateID
	ORDER BY [Client ID] DESC

	

END
