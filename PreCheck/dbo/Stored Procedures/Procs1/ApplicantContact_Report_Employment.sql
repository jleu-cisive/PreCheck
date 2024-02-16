/**************************************************************************************************************
-- Modified by AmyLiu on 09/11/2020 for phase3 of project: IntranetModule: Status-SubStatus
-- EXEC [dbo].[ApplicantContact_Report_Employment] '01/01/2020','09/10/2020','15440:13384','230:177'
**************************************************************************************************************/
CREATE PROCEDURE [dbo].[ApplicantContact_Report_Employment]
	@StartDate DATE, @EndDate DATE, @CLNO VARCHAR(MAX) = NULL, @Affiliate VARCHAR(MAX) = NULL
AS
	SET NOCOUNT ON;
	
	--declare 	@StartDate DATE='01/01/2020', 
	--			@EndDate DATE = '09/10/2020', 
	--			@CLNO VARCHAR(MAX) = '15440:13384', 
	--			@Affiliate VARCHAR(MAX) = '230:177'

	SELECT
		a.APNO as 'Report Number',
		CONCAT(a.First, ' ', a.Last) AS 'Applicant Name',
		e2.employer as 'Component Description',
		ss.Description as 'Status',
		isnull(sss.sectsubStatus,'') as 'SubStatus',
		--(SELECT e.Employer FROM Empl AS e WHERE e.EmplID = ac.SectionUniqueID) AS 'Component Description',
		--(SELECT ss.Description FROM Empl AS e INNER JOIN dbo.SectStat ss ON e.SectStat=ss.Code WHERE e.EmplID = ac.SectionUniqueID) AS 'Status', -- Modified by Humera Ahmed for HDT#52384
		--(select distinct isnull(sss.sectsubstatus,'')  from dbo.Empl e2 left join dbo.SectSubStatus sss on e2.sectstat =sss.sectstatusCode and e2.sectsubstatusID = sss.sectsubstatusid and e2.emplID= ac.SectionUniqueID) as SubStatus,
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
		left join dbo.Empl e2 on e2.emplID= ac.SectionUniqueID
		left join dbo.sectstat ss on e2.sectstat = ss.code
		left join dbo.sectsubstatus sss on e2.sectstat = sss.SectStatusCode and e2.sectsubstatusID = sss.sectsubstatusID
	WHERE CONVERT(DATE, ac.CreateDate) >= @StartDate
		AND CONVERT(DATE, ac.CreateDate) <= @EndDate
		AND ac.ApplSectionID = 1 
		--and refAf.AffiliateID IN (SELECT CAST(splitdata AS int) from fnSplitString(@Affiliate, ':'))
		AND( ISNULL( @Affiliate,'0')='0' OR refAf.AffiliateID IN (SELECT CAST(splitdata AS int) from fnSplitString(@Affiliate, ':') ) )
		AND ( ISNULL(@CLNO,'0')='0' OR a.CLNO IN (SELECT CAST(splitdata AS int) from fnSplitString(@CLNO, ':') ) )

		order by refaf.AffiliateID, a.CLNO, a.apno

