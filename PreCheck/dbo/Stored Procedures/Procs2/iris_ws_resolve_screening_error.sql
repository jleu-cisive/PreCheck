-- Alter Procedure iris_ws_resolve_screening_error
CREATE PROCEDURE [dbo].[iris_ws_resolve_screening_error]
    @vendor_id int,
    @county_no int,
    @ref varchar(10)
AS
DECLARE @temp CHAR(1);
BEGIN
    UPDATE dbo.crim 
        SET clear = 'Y'
    FROM
        dbo.crim C
        INNER JOIN dbo.TblCounties CO ON C.cnty_no = co.cnty_no
        INNER JOIN dbo.appl A ON C.apno = A.apno
        LEFT OUTER JOIN dbo.iris_researchers R ON C.vendorid = R.r_id
    WHERE
        (UPPER(C.clear) = 'E')
        AND C.vendorid = @vendor_id
        AND C.cnty_no = @county_no;
  
    UPDATE dbo.crim 
        SET clear = 'Z'
    FROM
        dbo.crim C
        INNER JOIN dbo.TblCounties CO ON C.cnty_no = CO.cnty_no
        INNER JOIN dbo.appl A ON C.apno = A.apno
        LEFT OUTER JOIN dbo.iris_researchers R ON C.vendorid = R.r_id
    WHERE
        (UPPER(C.clear) = 'X')
        AND C.vendorid = @vendor_id
        AND C.cnty_no = @county_no;
END
