-- =============================================
-- Author:		Prasanna
-- Create date: 9/20/2017
-- Description:	Billing Address and Tax Locale Audit
-- =============================================
CREATE PROCEDURE [dbo].[BillingAddressAndTaxLocaleAudit] 	
AS
BEGIN	
SET NOCOUNT ON;	
	 
	select  c.CLNO as [Client ID], c.Name as [Client Name], ra.Affiliate, c.CAM, c.LastInvDate as [Date of Last Activity], c.Addr1 as [Address1], 
	c.Addr2 as [Address2],c.City,c.State,c.Zip,c.AttnTo, c.BillingAddress1,c.BillingAddress2,c.BillingCity,c.BillingState,c.BillingZip, rts.TaxStatus, 
	rtl.TaxLocale, c.BillCycle as [Billing Group], ccb.LockPackagePricing as [Package Locking Checked (Y or N)], ccb.NoPackageNoBill as [No Package/No Bill Check (Y or N)],
	c.IsTaxExempt as[Tax Exempt Checked (Y or N)], c.TaxExemptionNumber, c.TaxExemptVerifiedUserID as [Verified By], c.TaxExempVerifiedDate as [Verified date] from  Client c
	inner join ClientConfig_Billing ccb on ccb.CLNO = c.CLNO
	inner join refAffiliate ra on c.AffiliateID = ra.AffiliateID
	inner join refTaxStatus rts on c.TaxStatusID = rts.TaxStatusID
	inner join refTaxLocale rtl on c.TaxLocaleID = rtl.TaxLocaleID
   
SET NOCOUNT OFF


END
