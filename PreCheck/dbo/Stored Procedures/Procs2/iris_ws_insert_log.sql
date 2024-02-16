 CREATE PROCEDURE [dbo].[iris_ws_insert_log]
    @entity_name VARCHAR(35),
    @order_id BIGINT,
    @data_id BIGINT,
    @log_item_type VARCHAR(35),
    @Created_on DATETIME
AS
BEGIN
	SET NOCOUNT ON;
    INSERT INTO dbo.iris_ws_log (entity_name, entity_id, data_id, log_item_type,  Created_on)
        VALUES (@entity_name, @order_id, @data_id, @log_item_type, @Created_on);
END
