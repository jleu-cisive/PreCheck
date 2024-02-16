--[dbo].[ApplicantContact_Report_ProfLic] '06/01/2019','08/31/2019','0','147'
CREATE PROCEDURE [dbo].[ApplicantContact_Report_ProfLic]
--DECLARE
	@StartDate DATE,-- = '06/01/2019', 
	@EndDate DATE,-- = '08/31/2019',
	@CLNO VARCHAR(MAX),-- = '0', --NULL, 
	@Affiliate VARCHAR(MAX)-- = '147'
AS
	SET NOCOUNT ON;
	if @clNo = '0' set @CLNO = null
	SELECT
		a.APNO as 'Report Number',
		CONCAT(a.First, ' ', a.Last) AS 'Applicant Name',
		(SELECT p.Lic_Type FROM ProfLic AS p WHERE p.ProfLicID = ac.SectionUniqueID) AS 'Component Description',
		(SELECT ss.Description FROM ProfLic AS p INNER JOIN dbo.SectStat ss ON p.SectStat=ss.Code WHERE p.ProfLicID = ac.SectionUniqueID) AS 'Status', -- Modified by Humera Ahmed for HDT#52384
		a.EnteredVia AS 'Order Method',
		a.UserID AS CAM,
		c.CLNO as 'Client Number',
		c.Name AS 'Client Name',
		refAf.AffiliateID AS 'Affiliate Number',
		refAf.Affiliate,
		ISNULL(hevFacil.IsOneHR,0) AS IsOneHR,
		rmc.ItemName AS 'Method Of Contact',
		rrc.ItemName AS 'Reason for Contact',
		ac.Investigator,
		FORMAT(ac.CreateDate, 'MM/dd/yyyy hh:mm tt') AS 'Date of Contact'
	FROM ApplicantContact AS ac WITH (NOLOCK)
		INNER JOIN Appl AS a WITH (NOLOCK) ON a.APNO = ac.APNO
		INNER JOIN Client AS c WITH (NOLOCK) ON c.CLNO = a.CLNO
		INNER JOIN refMethodOfContact AS rmc WITH (NOLOCK) ON rmc.refMethodOfContactID = ac.refMethodOfContactID
		INNER JOIN refReasonForContact AS rrc WITH (NOLOCK) ON rrc.refReasonForContactID = ac.refReasonForContactID
		INNER JOIN ApplSections AS applS WITH (NOLOCK) ON applS.ApplSectionID = ac.ApplSectionID
		LEFT JOIN ( 
			SELECT DISTINCT 
				FacilityNum, 
				IsOneHR
			FROM HEVN.dbo.Facility WITH (NOLOCK)) AS hevFacil ON hevFacil.FacilityNum = a.DeptCode AND hevFacil.IsOneHR = 1
		LEFT JOIN refAffiliate as refAf WITH (NOLOCK) ON refAf.AffiliateID = c.AffiliateID
	WHERE CONVERT(DATE, ac.CreateDate) >= @StartDate
		AND CONVERT(DATE, ac.CreateDate) <= @EndDate
		AND ac.ApplSectionID = 4
		AND refAf.AffiliateID in (SELECT CAST(splitdata AS int) from fnSplitString(@Affiliate, ':'))
		--and a.CLNO in (SELECT CAST(splitdata AS int) from fnSplitString(@CLNO, ':'))
		AND(IsNull(@Affiliate,'') = '' 
		OR LEN(@Affiliate) = 0 
			OR refAf.AffiliateID IN (SELECT CAST(splitdata AS int) from fnSplitString(@Affiliate, ':')))
		AND (@CLNO IS NULL 
			OR LEN(@CLNO) = 0 
			OR a.CLNO IN (SELECT CAST(splitdata AS int) from fnSplitString(@CLNO, ':')))
