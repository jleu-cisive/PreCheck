-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 12/18/2014
-- Description:	Check if the ConfigurationKey 'ClientAccess_CorporateView' exists for the CLNO
-- EXEC [ClientAccess_CheckConfigKey_CorporateView] 7519,
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_CheckConfigKey_CorporateView] 
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@ReturnValue varchar(500) output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @ConfigKey varchar(50)

SET @ConfigKey ='ClientAccess_CorporateView' 


SET @ReturnValue = (Select ISNULL((SELECT LOWER(VALUE) FROM ClientConfiguration WHERE CLNO = @CLNO and ConfigurationKey = @ConfigKey),'FALSE') )


   
SET NOCOUNT OFF


END
