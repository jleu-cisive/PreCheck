-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_PullClientInformation] 
	-- Add the parameters for the stored procedure here
	@CLNO int	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT CLNO,Name,Addr1,Addr2,City,State,Zip,AttnTo,BillingAddress1,BillingAddress2,
	BillingCity,BillingState,BillingZip FROM Client WHERE CLNO = @CLNO

SET NOCOUNT OFF
END




