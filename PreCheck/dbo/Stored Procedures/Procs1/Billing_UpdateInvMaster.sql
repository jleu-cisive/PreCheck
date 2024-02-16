
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/18/2013
-- Description:	Update InvMaster Printed =1 
-- =============================================
CREATE PROCEDURE [dbo].[Billing_UpdateInvMaster] 
	-- Add the parameters for the stored procedure here
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.InvMaster SET Printed = '1' WHERE Printed = '0'
END

