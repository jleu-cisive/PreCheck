CREATE PROCEDURE [dbo].[Iris_ws_Unlock_New_Orders] 
	@screening_ID int
AS

BEGIN	
	UPDATE Crim SET inUseByIntegration = NULL
	WHERE crimid = @screening_ID and InUseByIntegration like 'IntegrationManagerNew%'
END