CREATE PROCEDURE [dbo].[iris_ws_errormessage]
    @vendor_id int,
    @county_no int,
    @dev varchar(10)
AS
BEGIN
    SELECT 'Web Service Message goes here' as errormessage
END
