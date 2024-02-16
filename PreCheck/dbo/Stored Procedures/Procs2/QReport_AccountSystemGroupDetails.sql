-- =============================================
-- Author:	Abhijit Awari
-- Create date: 10/12/2022
-- Description:	Qreport that pulls a list of all Accounts in Oasis
-- =============================================
Create PROCEDURE [dbo].[QReport_AccountSystemGroupDetails] 
	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
	SELECT c.CLNO, c.Name as ClientName, r.AffiliateID,r.Affiliate, c.[Accounting System Grouping] as [Accounting System Group], 
	c.BillCycle as [Billing Group], (select max(a.ApDate) from Precheck.dbo.Appl (nolock) a where a.clno= c.clno) as LastReportDate 
	FROM Client(nolock) c
	inner join refAffiliate(nolock) r on r.AffiliateID=c.AffiliateID
	WHERE c.IsInactive = 0   
	Order by c.clno

END