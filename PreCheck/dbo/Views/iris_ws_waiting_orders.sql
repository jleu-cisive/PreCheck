
CREATE VIEW [dbo].[iris_ws_waiting_orders]
AS
SELECT
    VT.code AS vendor_type,
    ORD.alt_id AS order_key,
    /*
    CURRENT "clear" DEFINITIONS:
    "Record Found": "F"
    "Clear": "T"
    "Possible": "P"
    "Ordered": "O"
    "Pending": "R"
    "Needs Review": ""
    // "W" stands for "waiting" and was added by integrations
    //statuses go from '' -> R -> M -> O | W -> F | T | P
    
    CASE
      WHEN SC.order_status IS NULL THEN 'New'
      ELSE SC.order_status
    END AS order_status,
    */
    CASE
        WHEN (C.clear IS NULL)
          OR (C.clear = '')
          OR (C.clear = 'R')
          OR (C.clear = 'E')
          OR (C.clear = 'M') THEN 'New'
        WHEN (C.clear = 'O')
          OR (C.clear = 'X')
          OR (C.clear = 'W') THEN 'InProgress'
        ELSE 'Completed'
    END AS order_status,
    A.APNO AS applicant_id,
    C.CrimID AS screening_id,
    CASE
        /*
        * "is_criminal_case_record" is meant to mark records which
        * arise from criminal cases found in an order's results
        * and which are not part of the order itself. These records
        * are not excluded by this query for performance reasons:
        * i.e. the "LEFT OUTER JOIN" below is faster than a "WHERE
        * NOT IN (SELECT..)" statement. The caller of this query
        * needs to inspect "is_criminal_case_record" and include or
        * exclude appropriately.
        */
        WHEN CC.id IS NOT NULL THEN 'true'
        ELSE 'false'
    END AS is_criminal_case_record,
    /*
     * Only records for which "is_criminal_case_record" = true
     * should have a "parent_screening_id". Parent screenings
     * are ordered screenings from which these records arise
     * as results (from the criminal cases found in the results).
     */
    CC.screening_id AS parent_screening_id,
    VS.id AS vendor_search_id,
    'criminal' AS search_type,
    VS.search_type_qualifier AS search_qualifier, 
    VS.court_type AS court_type,
    VS.country_code AS country_code,
    VS.region AS region,
    VS.county AS county,
    CASE WHEN A.Last = '' THEN NULL ELSE A.Last END AS last_name,
    CASE WHEN A.First = '' THEN NULL ELSE A.First END AS first_name,
    CASE WHEN A.Middle = '' THEN NULL ELSE A.Middle END AS middle_name,
    CASE
        WHEN UPPER(A.Sex) = 'M' THEN 'male'
        WHEN UPPER(A.Sex) = 'F' THEN 'female'
        ELSE 'unspecified'
    END AS sex,
    CASE WHEN A.DOB = '' THEN NULL ELSE CONVERT(CHAR(10), A.DOB, 102) END AS dob,
    CASE WHEN A.SSN = '' THEN NULL ELSE A.SSN END AS ssn,
    CASE WHEN A.Alias1_Last = '' THEN NULL ELSE A.Alias1_Last END AS last_name_1,
    CASE WHEN A.Alias1_First = '' THEN NULL ELSE A.Alias1_First END AS first_name_1,
    CASE WHEN A.Alias1_Middle = '' THEN NULL ELSE A.Alias1_Middle END AS middle_name_1,
    CASE WHEN A.Alias2_Last = '' THEN NULL ELSE A.Alias2_Last END AS last_name_2,
    CASE WHEN A.Alias2_First = '' THEN NULL ELSE A.Alias2_First END AS first_name_2,
    CASE WHEN A.Alias2_Middle = '' THEN NULL ELSE A.Alias2_Middle END AS middle_name_2,  
    CASE WHEN A.Alias3_Last = '' THEN NULL ELSE A.Alias3_Last END AS last_name_3,
    CASE WHEN A.Alias3_First = '' THEN NULL ELSE A.Alias3_First END AS first_name_3,
    CASE WHEN A.Alias3_Middle = '' THEN NULL ELSE A.Alias3_Middle END AS middle_name_3,
    CASE WHEN A.Alias4_Last = '' THEN NULL ELSE A.Alias4_Last END AS last_name_4,
    CASE WHEN A.Alias4_First = '' THEN NULL ELSE A.Alias4_First END AS first_name_4,
    CASE WHEN A.Alias4_Middle = '' THEN NULL ELSE A.Alias4_Middle END AS middle_name_4,
    CASE WHEN Datalength(C.CRIM_SpecialInstr) = 0 THEN NULL 
    ELSE C.CRIM_SpecialInstr END AS special_instructions,
    C.txtlast, C.txtalias, C.txtalias2, C.txtalias3, C.txtalias4
FROM [dbo].[Crim] C
    INNER JOIN dbo.Appl A ON C.APNO = A.APNO
    /* 
     * send only those order which are ready for delivery. Join to iris_ws_ready_for_delivery where delivered = 1 
     * accomplishes the same thing
     */
    INNER JOIN dbo.iris_ws_ready_for_delivery RD ON (C.crimid = RD.screening_id) and (RD.delivered = 0) 
    /* 
     * no need to filter on delivery-type, the "iris_ws_vendor_searches" join accomplishes the same thing
     */
    INNER JOIN [dbo].[iris_ws_vendor_searches] VS ON (C.CNTY_NO = VS.county_id) AND (C.VendorID = VS.vendor_id)
    INNER JOIN [dbo].[iris_ws_vendor_type] VT ON VS.vendor_type_id = VT.id
    LEFT OUTER JOIN [dbo].[iris_ws_screening] SC ON C.CrimID = SC.crim_id
    LEFT OUTER JOIN [dbo].[iris_ws_order] ORD ON SC.order_id = ORD.id
    LEFT OUTER JOIN [dbo].[iris_ws_criminal_case] CC ON (ORD.id = CC.screening_id) AND (C.caseno = CC.case_number)
/*
CURRENT "Clear" DEFINITIONS:
F: "Record Found"
T: "Clear"
P: "Possible Record Found"
O: "Ordered"
R: "Pending" i.e. "ready to order", not "ordered and in progress"
w: "Waiting, but ordered and in progress"
'' (blank): "Needs Review" i.e. review before being ordered
*
clear statuses go from '' -> R -> M -> O | W -> F | T | P
*/
WHERE (C.[Clear] IN ('O','W','X'))
  AND (SC.is_confirmed = 'F')
  AND C.IsHidden = 0;
