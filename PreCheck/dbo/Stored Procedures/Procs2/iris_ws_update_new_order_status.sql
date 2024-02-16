
CREATE PROCEDURE [dbo].[iris_ws_update_new_order_status]
    @screening_id BIGINT
AS
DECLARE @ts DATETIME;
BEGIN
    SET @ts = GETDATE();

	UPDATE crim SET
	  [clear] = 'W',
      irisordered = @ts,
	  ordered = CONVERT(char(8), @ts, 1) + SPACE(1) + CONVERT(char(5), @ts, 8)
	  WHERE (crimid = @screening_id) and clear = 'M'
	    AND IsHidden = 0 -- 01/16/2019 -- [Deepak] -- Get only reportable Crim Records;

	EXEC [dbo].[Iris_ws_Unlock_New_Orders] 
	@screening_id;
END
