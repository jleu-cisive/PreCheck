
 CREATE PROCEDURE [dbo].[iris_ws_fetch_screening_id]
    @order_id BIGINT,
    @crim_id BIGINT,
    @vendor_search_id BIGINT,
    @Created_On DATETIME,
    @screening_id BIGINT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @exists CHAR(1);
    SET @exists = 'F';    

    SELECT
        @exists = 'T',
        @screening_id = id
        FROM dbo.iris_ws_screening  (NOLOCK)
        WHERE order_id = @order_id
        AND crim_id = @crim_id;

    IF (@exists <> 'T') 
    BEGIN
        INSERT INTO dbo.iris_ws_screening (order_id, crim_id, vendor_search_id, order_status, result_status,  Created_on, updated_on)
            VALUES (@order_id, @crim_id, @vendor_search_id, 'New', 'unspecified', @Created_On, @Created_On);
            
	       SET @screening_id = SCOPE_IDENTITY();

    END

END
