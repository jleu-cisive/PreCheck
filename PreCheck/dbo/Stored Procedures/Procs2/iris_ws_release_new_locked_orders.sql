CREATE PROCEDURE [dbo].[iris_ws_release_new_locked_orders]
    @time_stamp varchar(50)
AS

BEGIN
    
	UPDATE crim SET
	  InUseByIntegration = NULL
	  WHERE InUseByIntegration = @time_stamp;

END



