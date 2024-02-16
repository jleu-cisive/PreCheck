CREATE PROCEDURE [dbo].[iris_ws_update_order_status]
    @screening_id BIGINT,
    @clear varchar(1)
AS
DECLARE @ts DATETIME;
BEGIN
    SET @ts = GETDATE();

if @clear = 'P' OR @clear = 'T' or @clear = 'F'
	UPDATE crim SET
	  [clear] = @clear --'W'
	  WHERE (crimid = @screening_id);
END
