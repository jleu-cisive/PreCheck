CREATE PROCEDURE [dbo].[iris_ws_message]
    @vendor_id int,
    @county_no int,
    @dev varchar(10)
AS
BEGIN
    --SELECT 'Web Service Message for GROUP goes here - JML 1' as ws_message;
    select null as ws_message;
END
