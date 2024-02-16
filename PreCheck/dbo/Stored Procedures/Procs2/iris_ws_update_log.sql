CREATE PROCEDURE [dbo].[iris_ws_update_log]
    @entity_name VARCHAR(35),
    @entity_id BIGINT,
    @item_type VARCHAR(35),
    @data_key BINARY(20),
    @data TEXT
AS
DECLARE @data_id BIGINT;
DECLARE @utc DATETIME;
BEGIN
    SET @utc = GETUTCDATE();

    EXECUTE iris_ws_fetch_data_id
        @data_key = @data_key,
        @data = @data,
        @data_id = @data_id OUTPUT;

    EXECUTE iris_ws_insert_log
        @entity_name = @entity_name,
        @order_id = @entity_id,
        @data_id = @data_id,
        @log_item_type = @item_type,
        @created_on = @utc;
END
