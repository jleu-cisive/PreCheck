CREATE PROCEDURE [dbo].[iris_ws_log_order]
    @order_key UNIQUEIDENTIFIER,
    @vendor_type VARCHAR(10),
    @applicant_id BIGINT,
    @order_id BIGINT OUTPUT
AS
DECLARE @utc DATETIME;
BEGIN
    SET @utc = GETUTCDATE();

    EXECUTE iris_ws_fetch_order_id
        @order_key = @order_key,
        @vendor_type = @vendor_type,
        @applicant_id = @applicant_id,
        @created_on = @utc,
        @order_id = @order_id OUTPUT;
END
