CREATE PROCEDURE [dbo].[iris_ws_message_pending]
    @crimid int,
    @batchnumber int
AS
BEGIN
  -- IT SEEMS THIS IS NOT USED ANYMORE
    SELECT 'Web Service Message for individual records goes here - JML 3' as ws_message
END
