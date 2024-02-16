-- =========================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 08/30/2016
-- Description:	[Clients_with_Investigators_Assigned_and_Volume] '2017-01-01','2017-12-31'
-- =========================================================================================
CREATE PROCEDURE [dbo].[Clients_with_Investigators_Assigned_and_Volume] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT A.CLNO as CLNO, r.Affiliate, C.Name as ClientName, C.Investigator1, C.Investigator2 as Investigator2, C.CAM, Count(*) As Volume
FROM Client AS C(NOLOCK)
INNER JOIN Appl AS A(NOLOCK) ON C.CLNO = A.CLNO
INNER JOIN refAffiliate AS R(NOLOCK) ON C.AffiliateID = r.AffiliateID
WHERE A.ApDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
AND C.Investigator1 is not null and c.Investigator2 is not null
GROUP BY A.CLNO, r.Affiliate, C.Name, C.Investigator1, C.Investigator2, C.CAM
order by 1 
END
