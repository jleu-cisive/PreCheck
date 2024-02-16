-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetEmplPersRefComboCount] 
	-- Add the parameters for the stored procedure here
	@packageID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 0 + (SELECT includedcount from PackageService where packageid = @packageID and servicetype = 4) + 
(SELECT includedcount from PackageService where packageid = @packageID and servicetype = 7) As ComboCount
END

