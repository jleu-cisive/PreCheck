-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/01/2021
-- Description:	Add $3.25 Data Entry Pass Thru Fee for Applications entered through DEMI per CLeint Per Package.
-- Imported the spreadsheet Dana provided to Table BillingDataEntryPassthruFeeByClient 
-- =============================================
CREATE PROCEDURE dbo.Billing_AddDataEntryPassThruFeeByClientByPackage 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
INSERT INTO InvDetail 

SELECT a.APNO, 1 [Type], NULL [SubKey], NULL [SubKeyChar], 0 [Billed], NULL [InvoiceNumber], CURRENT_TIMESTAMP [CreateDate], 'Data Entry Service' [Description], 3.25 [Amount]
FROM dbo.Appl a
INNER JOIN dbo.BillingDataEntryPassthruFeeByClient de ON a.CLNO = de.CLNO 
INNER JOIN dbo.CLientPackages cp ON de.ClientPackagesId = cp.ClientpackagesID
INNER JOIN dbo.PackageMain pm ON A.Packageid = pm.PackageID
LEFT JOIN dbo.InvDetail i ON a.apno = i.apno AND i.Description ='Data Entry Service'
WHERE a.EnteredVia = 'DEMI' 
	AND a.Billed = 0 
	AND i.InvDetID IS NULL 
	AND a.apdate > '11/01/2021'



END
