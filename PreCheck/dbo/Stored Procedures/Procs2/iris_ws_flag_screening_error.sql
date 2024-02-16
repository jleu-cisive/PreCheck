
CREATE PROCEDURE [dbo].[iris_ws_flag_screening_error]
   @screening_id INT
AS
--DECLARE @status CHAR(1);
BEGIN
SET NOCOUNT ON;
        UPDATE dbo.crim SET [clear] =  CASE WHEN [clear] IN ('R','M') THEN 'E'
											WHEN [clear] IN ('O','W') THEN 'X' 
											ELSE [clear] END ,
            readytosend = CASE WHEN [clear] IN ('R','M') THEN 0 ELSE readytosend END ,
			 batchnumber = NULL,
			 [status] = NULL
            WHERE crimid = @screening_id
			AND [clear] IN ('R','M','O','W') 
			OPTION (MAXDOP 1);

    --SELECT
    --    @status = [clear]
    --    FROM dbo.crim
    --    WHERE crimid = @screening_id;
        
    --IF(@status IN ('R', 'M'))
    --BEGIN
    --    UPDATE dbo.crim SET
    --        [clear] = 'E',
    --        readytosend = 0,
			 --batchnumber = NULL,
			 --[status] = NULL
    --        WHERE crimid = @screening_id;
    --END ELSE
    --IF (@status IN ('O','W'))
    --BEGIN
    --    UPDATE dbo.crim
    --        SET [clear] = 'X',
			 --batchnumber = NULL,
			 --[status] = NULL
    --        WHERE crimid = @screening_id;
    --END
--Exec dbo.iris_ws_unassign_batch_number
--      @screening_id = @screening_id;
END

















