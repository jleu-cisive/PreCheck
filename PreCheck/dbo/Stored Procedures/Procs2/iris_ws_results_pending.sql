-- Alter Procedure iris_ws_results_pending
CREATE PROCEDURE [dbo].[iris_ws_results_pending]
    @batchnumber int
AS
BEGIN
    SELECT DISTINCT 
        C.crimid, 
        C.apno, 
        C.irisordered,
        /*
        CASE
            WHEN (UPPER(C.clear) = 'W') AND (CC.ID IS NOT NULL) THEN 'V'
            ELSE C.clear
        END AS [clear],
        */
        C.[clear],
        C.cnty_no,
        C.b_rule,
        C.ordered,
        A.[first],
        A.middle,
        A.[last],
        C.county, 
        C.batchnumber,
        CO.a_county,
        CO.state,
        CO.a_county + ', ' + CO.state as zcounty, 
        (CASE clear
            WHEN 'X' THEN (SELECT TOP 1 CAST(D.data AS VARCHAR(1000))
                FROM iris_ws_log L
                INNER JOIN iris_ws_log_data D ON D.id = L.data_id
                INNER JOIN iris_ws_screening SCR ON (SCR.id = L.entity_id)
                WHERE (UPPER(L.entity_name) = 'SCREENING')
                  AND (L.log_item_type LIKE '%ERROR%')
                  AND (SCR.crim_id = C.crimid)
                ORDER BY L.created_on DESC)
            ELSE NULL
        END) AS ws_message
    FROM crim C --(index = ix_btchirisrec)
    INNER JOIN appl A ON C.apno = A.apno 
    INNER JOIN dbo.TblCounties CO ON C.cnty_no = CO.cnty_no 
    LEFT OUTER JOIN iris_ws_screening SCR ON C.parentcrimid = SCR.crim_id
    LEFT OUTER JOIN iris_ws_criminal_case CC ON SCR.id = CC.screening_id
    WHERE (UPPER(C.iris_rec) = 'YES')
        AND (C.batchnumber = @batchnumber)
        -- "C.clear <> 'F'" hides screenings which have criminal-cases
        AND (C.clear <> 'F')
        AND UPPER(A.apstatus) IN ('P', 'W', 'F')
        -- hide older records with duplicate batch numbers
        AND (YEAR(C.irisordered) > 2007)
    ORDER BY A.[last], C.apno, CO.state, CO.a_county;
END
