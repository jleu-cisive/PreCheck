-- Alter Procedure iris_ws_orders



CREATE PROCEDURE [dbo].[iris_ws_orders]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        R.r_name,
        R.r_firstname,
        C.b_rule,
        R.r_lastname, 
        ISNULL(C.readytosend, 0) AS readytosend,
        R.R_id AS vendorid,
        R.r_delivery,
        C.cnty_no,
        MIN(crimenteredtime) AS crim_time,
        CO.a_county AS county, 
        CO.state,
        C.iris_rec,
        C.clear 
    FROM
        dbo.crim C WITH (NOLOCK)
        INNER JOIN dbo.TblCounties CO WITH (NOLOCK) ON C.cnty_no = CO.cnty_no
        INNER JOIN dbo.appl A WITH (NOLOCK) ON C.apno = A.apno
        LEFT OUTER JOIN dbo.iris_researchers R WITH (NOLOCK) ON C.vendorid = R.r_id
    WHERE
        (UPPER(R.r_delivery) LIKE 'WEB%SERVICE')
        AND (UPPER(C.clear) IN ('R','E'))
        AND (UPPER(C.iris_rec) = 'YES')
        AND (C.batchnumber IS NULL) 
        AND (A.inuse IS NULL )
        AND (UPPER(A.apstatus) IN ('P','W'))
		AND C.IsHidden = 0
        GROUP BY
          R.r_name,
          R.r_firstname,
          C.b_rule,
          R.r_lastname,
          ISNULL(C.readytosend, 0),
          R.r_id,
          R.r_delivery,
          C.cnty_no,
          CO.a_county,
          CO.state,
          C.iris_rec,
          C.clear
		  
		  ORDER BY crim_time asc;
    SET NOCOUNT OFF;
END
