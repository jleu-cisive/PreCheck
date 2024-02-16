CREATE PROCEDURE [dbo].[iris_ws_unassign_batch_number]
    @screening_id INT
AS
DECLARE @order_id BIGINT;
BEGIN
  -- This is used to unassign batch number when orders error out
  UPDATE crim SET
     batchnumber = NULL,
     [status] = NULL
     WHERE crimid = @screening_id;
     
     
 /* DELETE FROM iris_ws_log 
    WHERE UPPER(entity_name) = 'SCREENING'
      AND (entity_id IN (
        SELECT id
          FROM iris_ws_screening
          WHERE crim_id = @screening_id
      ));
      
  SELECT
    @order_id = order_id
    FROM iris_ws_screening 
    WHERE crim_id = @screening_id;
    
  DELETE FROM iris_ws_screening
    WHERE crim_id = @screening_id;
    
  DELETE FROM iris_ws_order
    WHERE id = @order_id; */
END
