-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/04/2017
-- Description:	Billing Application for checking the locked package for an apno
-- =============================================
CREATE PROCEDURE Billing_CheckLockedPackage
	-- Add the parameters for the stored procedure here
	@Apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ISNULL(PrecheckChallenge,0) as precheckchallenge,ISNULL(PackageID,-1) as packageid,ad.packagecode 
	FROM Appl a 
	left join applclientdatahistory ad on a.apno = ad.apno 
	WHERE a.APNO = @Apno
END
