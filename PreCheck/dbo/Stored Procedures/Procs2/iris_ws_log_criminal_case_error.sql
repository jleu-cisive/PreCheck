CREATE PROCEDURE [dbo].[iris_ws_log_criminal_case_error]
    @vendor_type VARCHAR(10),
    @order_key UNIQUEIDENTIFIER,
    @applicant_id BIGINT,
    @screening_id BIGINT,
    @case_number VARCHAR(50),
    @vendor_search_id BIGINT,
    @data_key BINARY(20),
    @data TEXT
AS
DECLARE @exists CHAR(1);
DECLARE @utc DATETIME;
DECLARE @order_id BIGINT;
DECLARE @screening_log_id BIGINT;
DECLARE @data_id BIGINT;
DECLARE @criminal_case_log_id BIGINT;
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
    
    EXECUTE iris_ws_fetch_criminal_case_id
        @screening_id = @screening_log_id,
        @case_number = @case_number,
        @created_on = @utc,
        @criminal_case_id = @criminal_case_log_id OUTPUT;
    
    EXECUTE iris_ws_fetch_data_id
        @data_key = @data_key,
        @data = @data,
        @data_id = @data_id OUTPUT;
    
    EXECUTE iris_ws_insert_log
        @entity_name = 'criminal-case',
        @order_id = @criminal_case_log_id,
        @data_id = @data_id,
        @log_item_type = 'error',
        @created_on = @utc;
END
