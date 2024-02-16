CREATE PROCEDURE [dbo].[iris_ws_confirm_order]
    @order_key UNIQUEIDENTIFIER
AS
BEGIN
   UPDATE
       iris_ws_screening
       SET is_confirmed = 'T'
       FROM iris_ws_screening S
       JOIN iris_ws_order O ON S.order_id = O.id
       WHERE O.alt_id = @order_key;
END
