CREATE PROCEDURE [dbo].[iris_ws_log_screening_error]
    @vendor_type VARCHAR(10),
    @order_key UNIQUEIDENTIFIER,
    @applicant_id BIGINT,
    @screening_id BIGINT,
    @vendor_search_id BIGINT,
    @data_key BINARY(20),
    @data TEXT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @exists CHAR(1);
	DECLARE @order_id BIGINT;
	DECLARE @screening_log_id BIGINT;
	DECLARE @utc DATETIME;
	DECLARE @data_id BIGINT;

    SET @utc = GETUTCDATE();

    EXECUTE dbo.iris_ws_fetch_order_id
        @order_key = @order_key,
        @vendor_type = @vendor_type,
        @applicant_id = @applicant_id,
        @Created_On = @utc,
        @order_id = @order_id OUTPUT;


    EXECUTE dbo.iris_ws_fetch_screening_id
        @order_id = @order_id,
        @crim_id = @screening_id,
        @vendor_search_id = @vendor_search_id,
        @Created_On = @utc,
        @screening_id = @screening_log_id OUTPUT;


    EXECUTE dbo.iris_ws_fetch_data_id
	    @data_key = @data_key,
        @data = @data,
        @data_id = @data_id OUTPUT;


    EXECUTE dbo.iris_ws_insert_log
        @entity_name = 'screening',
        @order_id = @screening_log_id,
        @data_id = @data_id,
        @log_item_type = 'error',
        @Created_On = @utc;
END


