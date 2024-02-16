
-- Alter View Iris_ws_vendor_searches1
CREATE View dbo.Iris_ws_vendor_searches1 as 
SELECT

    R.R_id AS vendor_id,

    C.cnty_no AS county_id,

    'felonyMisdemeanor' AS court_type,

    CASE 

      WHEN C.A_County LIKE '%state%' THEN 'statewide'

      ELSE 'county'

    END AS search_type_qualifier,

    CASE

      WHEN R.R_Name LIKE '%omni%' THEN 3      

      ELSE NULL

    END AS vendor_type,

    'US' AS country_code,

    C.State AS region,

    CASE 

      WHEN C.A_County LIKE '%state%' THEN NULL

      WHEN C.A_County LIKE '%district%' THEN NULL

      ELSE C.A_County

    END AS county

  FROM dbo.TblCounties C

      INNER JOIN Iris_Researcher_Charges RC ON C.cnty_no = RC.cnty_no

      INNER JOIN Iris_Researchers R ON RC.Researcher_id = R.R_id

  WHERE (R.R_Name LIKE '%omni%' )
