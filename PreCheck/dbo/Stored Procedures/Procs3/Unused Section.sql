-- =============================================
-- Author:		Humera Ahmed
-- Create date: 1/7/2018
-- Description:	Please create report called Unused Section Info that considers only the data in the Unused section of OASIS, with App Date between Start/End Date parameters.  
-- =============================================
CREATE PROCEDURE [dbo].[Unused Section] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	a.apno AS 'APNO'
			,CONVERT(VARCHAR(10), a.apdate, 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), a.apdate, 22), 11))  AS 'Report Open Date'
			,ISNULL(CONVERT(VARCHAR(10), a.CompDate, 101) + ' ' + LTRIM(RIGHT(CONVERT(CHAR(20), a.CompDate, 22), 11)),'N/A')  AS 'Report Closed Date'
			,a.CLNO AS 'Client#', c.Name AS 'Client Name', ra.Affiliate
			,a.First,a.Last,
			CASE WHEN count(e.ishidden) >= 1 then 'Yes - ' + e.Employer ELSE 'None' END AS 'Unused Employment',
			CASE WHEN count(c2.ishidden) >= 1 then 'Yes - ' + c2.County ELSE 'None' END AS 'Unused Crim',
			CASE WHEN count(edu.IsHidden) >= 1 THEN 'Yes - ' + edu.School ELSE 'None' END AS 'Unused Education',
			CASE WHEN count(pr.IsHidden) >= 1 THEN 'Yes - ' + pr.Name ELSE 'None' END AS 'Unused Reference',
			CASE WHEN count(pl.IsHidden) >=1 THEN 'Yes - ' + pl.Lic_No ELSE 'None' END AS 'Unused Professional Licenses',
			CASE WHEN count(c3.IsHidden) >= 1 THEN 'Yes' ELSE 'None' END AS 'Unused Credit',
			CASE WHEN count(mi.IsHidden) >=1 THEN 'Yes' ELSE 'None' END AS 'Unused Sanction Check' 
	FROM appl a 
		INNER JOIN client c ON a.clno = c.clno 
		INNER JOIN dbo.refAffiliate ra ON ra.AffiliateID = c.AffiliateID
		LEFT JOIN dbo.Empl e ON a.APNO =e.Apno AND e.IsHidden=1
		LEFT JOIN dbo.Crim c2 ON c2.APNO = a.APNO AND c2.IsHidden=1
		LEFT JOIN dbo.Educat edu ON edu.APNO = a.APNO AND edu.IsHidden=1
		LEFT JOIN dbo.PersRef pr ON pr.APNO = a.APNO AND pr.IsHidden=1
		LEFT JOIN dbo.ProfLic pl ON a.APNO = pl.Apno AND pl.ishidden = 1
		LEFT JOIN dbo.Credit c3 ON a.APNO = c3.APNO AND c3.ishidden =1
		LEFT JOIN dbo.MedInteg mi ON a.APNO = mi.APNO AND mi.IsHidden=1
	WHERE
		convert(date,a.apdate) >= @StartDate AND convert(date,a.apdate) <= dateadd(d,1,@EndDate)
		--AND a.ApStatus='P'
		--and (e.IsHidden!=0 or c2.IsHidden!=0 or edu.IsHidden!=0 or pl.IsHidden !=0 or c3.IsHidden !=0 OR pr.IsHidden!=0 OR mi.IsHidden!=0)
	group by 
		a.apno, a.apdate, a.CompDate, a.CLNO, c.Name, ra.Affiliate, a.First,a.Last, e.Employer
		, c2.County, e.IsHidden,c2.IsHidden, edu.ishidden, edu.School, pl.Lic_No,
		pl.IsHidden, c3.Vendor, c3.IsHidden,pr.Name, c2.clear, a.ApStatus,pr.IsHidden,mi.IsHidden
	having 
		(e.IsHidden=1 or c2.IsHidden=1 or edu.IsHidden=1 or pl.IsHidden=1 or c3.IsHidden =1 OR pr.IsHidden=1 OR mi.IsHidden=1)
	ORDER BY 
		a.apdate
END
