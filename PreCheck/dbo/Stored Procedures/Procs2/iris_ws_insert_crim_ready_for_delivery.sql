CREATE PROCEDURE [dbo].[iris_ws_insert_crim_ready_for_delivery]
     @screening_id int
AS

Declare @countScreeningID int;

BEGIN
 
   Set @countScreeningID = 0;

   select @countScreeningID = count(screening_ID) from iris_ws_ready_for_delivery
    where screening_ID = @screening_ID;

  if (@countScreeningID = 0)
   
   Begin
      INSERT INTO dbo.iris_ws_ready_for_delivery ( screening_ID, delivered) Values (@screening_ID, 0)
   End
	
END
