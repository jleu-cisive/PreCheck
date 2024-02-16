/*
	EXEC [iris_ws_resolve_error_order] 34521175
*/

CREATE PROCEDURE [dbo].[iris_ws_resolve_error_order]
    @crim_id INT
AS
DECLARE @vendor_id INT;
DECLARE @old_vendor_id INT;
BEGIN
    --SELECT
    --    @vendor_id = R.r_id,
    --    @old_vendor_id = R2.r_id
    --    FROM iris_researchers R
    --    INNER JOIN iris_researchers R2 ON R2.r_id = R.web_service_id
    --    INNER JOIN crim C ON C.vendorid = R2.r_id
    --    WHERE C.crimid = @crim_id
    --    ORDER BY R.r_id;
      
	-- VD -- 05/26/2020 - Commented the above code
    SELECT
        @vendor_id = R.r_id,
        @old_vendor_id = R.r_id
        FROM iris_researchers R
        --LEFT OUTER JOIN iris_researchers R2 ON R2.r_id = R.web_service_id
        INNER JOIN crim C ON C.vendorid = R.r_id
        WHERE C.crimid = @crim_id
        ORDER BY R.r_id;

    UPDATE crim SET
        vendorid = ISNULL(@vendor_id,'')
        WHERE crimid = @crim_id;
END
