CREATE PROCEDURE [dbo].[iris_ws_fetch_criminal_case_id]
    @screening_id BIGINT,
    @case_number VARCHAR(50),
    @created_on DATETIME,
    @criminal_case_id BIGINT OUTPUT
AS
DECLARE @exists CHAR(1);
BEGIN
    SET @exists = 'F';  
    
    SELECT
        @exists = 'T',
        @criminal_case_id = id
        FROM iris_ws_criminal_case
        WHERE screening_id = @screening_id
        AND case_number = @case_number;
        
    IF (@exists <> 'T') 
    BEGIN
        INSERT INTO iris_ws_criminal_case (screening_id, case_number, created_on)
            VALUES (@screening_id, @case_number, @created_on);
            
        SET @criminal_case_id = @@IDENTITY;
    END
END
