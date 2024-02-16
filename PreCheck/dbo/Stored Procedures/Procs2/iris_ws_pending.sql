-- Alter Procedure iris_ws_pending
CREATE PROCEDURE [dbo].[iris_ws_pending]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT
        C.status,
        C.ordered,
        R.r_name AS vendor,
        R.r_delivery,
        C.cnty_no,
        R.r_id AS vendorid,
        R.r_firstname,
        R.r_lastname, 
        C.batchnumber,
        C.iris_rec,
        CONVERT(numeric(7, 2), dbo.elapsedbusinessdays(C.ordered, GETDATE())) AS elapsed,
        CO.a_county,
        CO.state,
        CO.a_county + ' , ' + CO.state AS county,
        C.clear
    FROM dbo.appl A
        INNER JOIN dbo.crim C ON A.apno = C.apno
        INNER JOIN dbo.TblCounties CO ON C.cnty_no = CO.cnty_no
        LEFT OUTER JOIN dbo.iris_researchers R ON C.vendorid = R.r_id
    WHERE (UPPER(A.apstatus) IN ('P','W'))
        AND (UPPER(C.iris_rec) = 'YES')
        AND (UPPER(C.clear) IN ('O','W','X','V'))
        AND (C.batchnumber IS NOT NULL)
        AND (UPPER(R.r_delivery) LIKE 'WEB%SERVICE%')
    GROUP BY
        C.status,
        C.ordered,
        R.r_name,
        R.r_firstname,
        R.r_lastname,
        C.batchnumber, 
        R.r_id,
        R.r_delivery,
        C.county,
        C.iris_rec,
        C.cnty_no,
        CO.a_county,
        CO.state,
        C.clear
    ORDER BY
        CONVERT(numeric(7, 2), dbo.elapsedbusinessdays(C.ordered, GETDATE())) DESC;

    SET NOCOUNT OFF;
END
