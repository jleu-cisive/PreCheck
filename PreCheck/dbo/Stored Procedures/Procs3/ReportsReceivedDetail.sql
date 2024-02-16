-- =============================================
-- Modified By:	Deepak Vodethela
-- Create date: 05/23/2019
-- Description:	Reports Received Details
-- Excecution: EXEC [dbo].[ReportsReceivedDetail] '10/01/2020','10/20/2020'
-- Modified by Radhika Dereddy on 11/04/2020 to add PackageID, PackageDesc and EnteredVia
--- Modified by Sahithi Gangaraju on 06/1/2021 to remove duplicates in the results -added distinct
-- =============================================
CREATE PROCEDURE [dbo].[ReportsReceivedDetail]
	-- Add the parameters for the stored procedure here
 @StartDate DateTime,
 @EndDate DateTime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	SELECT distinct	CAST(c.CLNO AS VARCHAR(10)) AS CLNO, c.[Name] AS [Client Name], r.Affiliate, a.Apno AS [Report Number], 
			rc.ClientType AS [Client Type], a.ApDate AS [Received Date], a.EnteredVia, ISNULL(cp.PackageID, pm.PackageID) as PackageID,
			pm.PackageDesc as PackageOrdered, c.AffiliateID, r.Affiliate
	From Appl a(NOLOCK)  
	INNER JOIN Client C(NOLOCK) on a.CLno = c.CLno  
	INNER JOIN refClientType rc(NOLOCK) on c.ClientTypeID = rc.ClientTypeID  
	INNER JOIN refAffiliate as r(NOLOCK) on C.AffiliateID = r.AffiliateID 
	INNER JOIN ClientPackages cp on a.PackageID = cp.PackageiD 
	INNER JOIN PackageMain pm on cp.PackageID = pm.PackageID
	WHERE a.Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate) 
	ORDER BY clno  desc
END
