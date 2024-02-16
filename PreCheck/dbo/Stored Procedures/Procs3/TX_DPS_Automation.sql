-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/16/2020
-- Description:	TX DPS Automation
-- EXEC [TX_DPS_Automation] '09/15/2020','10/15/2020'
-- =============================================
CREATE PROCEDURE dbo.[TX_DPS_Automation]
	-- Add the parameters for the stored procedure here
@StartDate datetime,
@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
Select DISTINCT a.APNO, cr.CrimID, a.CLNO, c.Name, a.Apstatus, a.SSN, a.DOB, a.First, a.Middle, a.Last,
Cr.County, Cr.CNTY_NO, Cr.Ordered, Cr.Clear, Cr.Priv_Notes
FROM APPL a
INNER JOIN Client c ON a.CLNO =c.CLNO
INNER JOIN Crim cr ON a.APNO = cr.APNO AND cr.IsHidden =0
INNER JOIN ApplAlias al ON a.APNO = al.APNO AND al.IsActive = 1  AND al.IsPublicRecordQualified = 1
LEFT JOIN ApplAlias_Sections aas ON al.ApplAliasID = aas.ApplAliasID AND aas.ApplSectionID = 5 AND aas.IsActive = 1
WHERE (Cr.CNTY_NO = 2682 OR Cr.vendorid = 262) 
AND a.Apdate between @StartDate and @EndDate
ORDER BY 1 DESC


END
