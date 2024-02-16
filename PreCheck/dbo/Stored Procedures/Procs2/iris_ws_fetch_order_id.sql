CREATE PROCEDURE [dbo].[iris_ws_fetch_order_id]
    @order_key UNIQUEIDENTIFIER,
    @vendor_type VARCHAR(10),
    @applicant_id BIGINT,
    @Created_On DATETIME,
    @order_id BIGINT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @exists CHAR(1);
	DECLARE @vendor_type_id BIGINT;

    SET @exists = 'F';    

    SELECT
        @exists = 'T',
        @order_id = id
        FROM dbo.iris_ws_order (NOLOCK)
        WHERE alt_id = @order_key;

    IF (@exists <> 'T') 
    BEGIN
        SELECT
           @vendor_type_id = id
           FROM dbo.iris_ws_vendor_type (NOLOCK)
           WHERE code = @vendor_type;

        INSERT INTO iris_ws_order (alt_id, vendor_type_id, applicant_id,  Created_on)
	    VALUES (@order_key, @vendor_type_id, @applicant_id, @Created_On);

        SET @order_id = SCOPE_IDENTITY();
    END
END
