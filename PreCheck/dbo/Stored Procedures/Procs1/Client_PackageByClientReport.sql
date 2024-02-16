
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Client_PackageByClientReport]
	-- Add the parameters for the stored procedure here

AS
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

    SELECT DISTINCT [Name], dbo.Client.CLNO, City, State, Zip, Phone, Fax, Contact, Email, 
	HomeCounty, Addr1, Addr2, Addr3, IsInactive,MAX(InvDate) AS LastDateBilled, BillingStatus, 
	PackageDesc, DefaultPrice, dbo.ClientPackages.Rate AS PackagePrice 
	FROM dbo.Client
	LEFT OUTER JOIN dbo.ClientRates ON dbo.Client.CLNO = dbo.ClientRates.CLNO 
	LEFT OUTER JOIN dbo.ClientPackages ON dbo.Client.CLNO = dbo.ClientPackages.CLNO 
	LEFT OUTER JOIN  dbo.PackageService ON dbo.ClientPackages.PackageID = dbo.PackageService.PackageID 
	LEFT OUTER JOIN dbo.PackageMain ON dbo.PackageMain.PackageID = dbo.PackageService.PackageID 	
	LEFT OUTER JOIN dbo.InvMaster ON dbo.Client.CLNO = dbo.InvMaster.CLNO
	LEFT OUTER JOIN dbo.refBillingStatus ON dbo.Client.BillingStatusID = dbo.refBillingStatus.BillingStatusID
    GROUP BY [Name], dbo.Client.CLNO, City, State, Zip, Phone, Fax, Contact, Email, HomeCounty, Addr1, Addr2, 
	Addr3,IsInactive, BillingStatus, PackageDesc, DefaultPrice, dbo.ClientPackages.Rate 
	ORDER BY [Name], PackageDesc 
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
