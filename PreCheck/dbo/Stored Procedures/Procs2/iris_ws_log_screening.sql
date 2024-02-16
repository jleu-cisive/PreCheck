CREATE PROCEDURE [dbo].[iris_ws_log_screening]
    @vendor_type VARCHAR(10),
    @order_key UNIQUEIDENTIFIER,
    @applicant_id BIGINT,
    @screening_id BIGINT,
    @vendor_search_id BIGINT,
    @screening_log_id BIGINT OUTPUT
AS
DECLARE @order_id BIGINT;
DECLARE @utc DATETIME;
BEGIN
    SET @utc = GETUTCDATE();

    EXECUTE iris_ws_fetch_order_id
        @order_key = @order_key,
        @vendor_type = @vendor_type,
        @applicant_id = @applicant_id,
        @created_on = @utc,
        @order_id = @order_id OUTPUT;
    
    EXECUTE iris_ws_fetch_screening_id
        @order_id = @order_id,
        @crim_id = @screening_id,
        @vendor_search_id = @vendor_search_id,
        @created_on = @utc,
        @screening_id = @screening_log_id OUTPUT;
END
