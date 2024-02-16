 CREATE PROCEDURE [dbo].[iris_ws_fetch_data_id]

    @data_key BINARY(20),

    @data TEXT,

    @data_id BIGINT OUTPUT

AS

DECLARE @exists CHAR(1);

DECLARE @order_id BIGINT;

DECLARE @screening_log_id BIGINT;

DECLARE @utc DATETIME;

BEGIN

    SET @exists = 'F';    

    

    SELECT

        @exists = 'T',

        @data_id = id

        FROM dbo.iris_ws_log_data (NOLOCK)

        WHERE hash_key = @data_key;

    

    IF (@exists <> 'T') 

    BEGIN

        INSERT INTO dbo.iris_ws_log_data (hash_key, data)

            VALUES (@data_key, @data);

            

        SET @data_id = @@IDENTITY;

    END

END