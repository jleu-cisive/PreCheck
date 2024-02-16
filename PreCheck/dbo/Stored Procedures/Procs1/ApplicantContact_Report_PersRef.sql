
CREATE PROCEDURE [dbo].[ApplicantContact_Report_PersRef]
	@StartDate DATE, @EndDate DATE, @CLNO VARCHAR(MAX) = NULL, @Affiliate VARCHAR(MAX) = NULL
AS
	SET NOCOUNT ON;

	SELECT
		a.APNO as 'Report Number',
		CONCAT(a.First, ' ', a.Last) AS 'Applicant Name',
		(SELECT p.Name FROM PersRef AS p WHERE p.PersRefID = ac.SectionUniqueID) AS 'Component Description',
		(SELECT ss.Description FROM PersRef AS p INNER JOIN dbo.SectStat ss ON p.SectStat=ss.Code WHERE p.PersRefID = ac.SectionUniqueID) AS 'Status', -- Modified by Humera Ahmed for HDT#52384
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
		FORMAT(ac.CreateDate, 'MM/dd/yyyy hh:mm:ss') AS 'Date of Contact'
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
		AND ac.ApplSectionID = 3
		AND(@Affiliate IS NULL 
			OR LEN(@Affiliate) = 0 
			OR refAf.AffiliateID IN (SELECT CAST(splitdata AS int) from fnSplitString(@Affiliate, ':')))
		AND (@CLNO IS NULL 
			OR LEN(@CLNO) = 0 
			OR a.CLNO IN (SELECT CAST(splitdata AS int) from fnSplitString(@CLNO, ':')))
