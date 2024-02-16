
-- =============================================
-- Author:		Arindam  M
-- Create date: 02/03/2023
-- Description: Applicant Name Sources Report
--Ticket No - 79421 - Applicant Name Sources Report
--Parameters should be Apno, and have optional CLNO, AffiliateId, start date, end date options.  When left as "0" should assume All. 
-- EXEC [ApplicantNameSources_Report] '3328300', '0', '0', '05/01/2022','05/01/2022'
-- =============================================

CREATE PROCEDURE [dbo].[ApplicantNameSources_Report]
-- Add the parameters for the stored procedure here
@APNo int,
@CLNO VARCHAR(MAX),
@AffiliateID VARCHAR(MAX),
@StartDate date,
@EndDate date

AS
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END

	IF @CLNO = '0' 
	BEGIN  
		SET @CLNO = NULL  
	END

----if start date or end date is null, then last 30 days date range to be selected

	IF @StartDate IS NULL
		SET @StartDate=(SELECT GETDATE()-30)

	IF @EndDate IS NULL
		SET @EndDate=(SELECT GETDATE())

	IF @APNo IS NOT NULL
	BEGIN

		SELECT a.APNO, ISNULL(a.CLNO, '') AS CLNO, ISNULL(CL.Name, '') AS 'Client Name', ISNULL(a.First, '') AS 'First Name', ISNULL(a.Middle,'') AS 'Middle Name', ISNULL(a.Last, '') AS 'Last Name', 
				ISNULL(A.GENERATION, '') AS Generation, A.ApplAliasID, ISNULL(A.CreatedBy, '') AS CreatedBy, 
			   CASE WHEN a.IsPublicRecordQualified = 1 THEN 'T' ELSE 'F' END AS IsQualified, CL.AffiliateID, A.CreatedDate
		FROM dbo.ApplAlias a with (nolock)
			LEFT JOIN dbo.Client CL(NOLOCK) on CL.CLNO = a.CLNO
			LEFT JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = CL.AffiliateID
		WHERE a.APNO = @APNo

	END

	IF @APNo IS NULL
	BEGIN

		SELECT a.APNO, ISNULL(CAST(CL.CLNO AS VARCHAR), '') AS CLNO, ISNULL(CL.Name, '') AS 'Client Name', ISNULL(a.First, '') AS 'First Name', ISNULL(a.Middle,'') AS 'Middle Name', 
				ISNULL(a.Last, '') AS 'Last Name', 				ISNULL(A.GENERATION, '') AS Generation, A.ApplAliasID, ISNULL(A.CreatedBy, '') AS CreatedBy, 
				CASE WHEN a.IsPublicRecordQualified = 1 THEN 'T' ELSE 'F' END AS IsQualified, CL.AffiliateID, A.CreatedDate
		FROM dbo.ApplAlias a with (nolock)
			LEFT JOIN dbo.Client CL(NOLOCK) on CL.CLNO = a.CLNO
			LEFT JOIN refAffiliate RA(NOLOCK) on RA.AffiliateID = CL.AffiliateID
		WHERE (CAST(A.CreatedDate AS DATE) >= @StartDate  
		AND  CAST(A.CreatedDate AS DATE) <= @EndDate)
		AND (@CLNO IS NULL OR CL.CLNO IN (SELECT value FROM fn_Split(@CLNO,':')))
		AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))		

	END


END