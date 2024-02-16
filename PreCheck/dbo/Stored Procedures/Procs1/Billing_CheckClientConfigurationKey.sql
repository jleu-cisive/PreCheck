-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 11/18/2014
-- Description:	Get all the Clients for the Configuration Key 'AttachFilestoBilling'
-- =============================================
CREATE PROCEDURE [dbo].[Billing_CheckClientConfigurationKey] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @ConfigKey varchar(50)
DECLARE @Value varchar(500)

SET @ConfigKey ='Billing_AttachPdftoClients' 
SET @Value ='True'

SELECT CLNO FROM  ClientConfiguration WHERE ConfigurationKey = @ConfigKey and Value = @Value


   
SET NOCOUNT OFF


END
