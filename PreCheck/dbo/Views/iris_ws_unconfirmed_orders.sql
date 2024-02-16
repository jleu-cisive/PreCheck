


CREATE VIEW [dbo].[iris_ws_unconfirmed_orders]
AS
SELECT  top 10
    CASE
      WHEN R.R_Name LIKE '%omni%' THEN 'omnidata'      
      WHEN R.R_Name LIKE '%innov%' THEN 'innovative'      
      ELSE NULL
      END AS vendor_type,
    ORD.alt_id AS order_key,
  
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
        WHEN CC.id IS NOT NULL THEN 'true'
        ELSE 'false'
    END AS is_criminal_case_record,
    CC.screening_id AS parent_screening_id,
    VS.id AS vendor_search_id,
    'criminal' AS search_type,
    CASE 
      WHEN Co.A_County LIKE '%state%' THEN 'statewide'
      ELSE 'county'
      END AS search_qualifier,
     'felonyMisdemeanor' AS court_type, 
     'US' AS country_code,
     Co.State AS region,
    CASE 
      WHEN Co.A_County LIKE '%state%' THEN NULL
       ELSE Co.A_County
      END AS county,
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
    Inner join dbo.iris_researcher_charges VS  on  C.cnty_no = VS.cnty_no
       inner join dbo.counties Co on (co.cnty_no = vs.cnty_no)
       inner join  dbo.Iris_Researchers R on (VS.researcher_id = r.r_id) and (r.r_delivery = 'WEB SERVICE') 
       and r_vendorconfirmation = 1
  
    inner JOIN [dbo].[iris_ws_screening] SC ON C.CrimID = SC.crim_id
    inner JOIN [dbo].[iris_ws_order] ORD ON SC.order_id = ORD.id
    LEFT OUTER JOIN [dbo].[iris_ws_criminal_case] CC ON (ORD.id = CC.screening_id) AND (C.caseno = CC.case_number)
WHERE (C.[Clear] IN ('F','T','P','V')) AND (SC.is_confirmed = 'F') AND c.IsHidden = 0;
