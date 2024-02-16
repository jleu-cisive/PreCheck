CREATE PROCEDURE [dbo].[iris_ws_log_order_error]
    @vendor_type VARCHAR(10),
    @order_key UNIQUEIDENTIFIER,
    @applicant_id BIGINT,
    @data_key BINARY(20),
    @data TEXT
AS
DECLARE @exists CHAR(1);
DECLARE @utc DATETIME;
DECLARE @order_id BIGINT;
DECLARE @data_id BIGINT;
BEGIN
    SET @utc = GETUTCDATE();

    EXECUTE iris_ws_fetch_order_id
        @order_key = @order_key,
        @vendor_type = @vendor_type,
        @applicant_id = @applicant_id,
        @created_on = @utc,
        @order_id = @order_id OUTPUT;
    
    EXECUTE iris_ws_fetch_data_id
        @data_key = @data_key,
        @data = @data,
        @data_id = @data_id OUTPUT;
        
    EXECUTE iris_ws_insert_log
        @entity_name = 'order',
        @order_id = @order_id,
        @data_id = @data_id,
        @log_item_type = 'error',
        @created_on = @utc;
END
