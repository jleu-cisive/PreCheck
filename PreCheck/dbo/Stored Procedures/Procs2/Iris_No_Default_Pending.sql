CREATE PROCEDURE [dbo].[Iris_No_Default_Pending] AS
SELECT DISTINCT 
                       crim.apno As AppNo,dbo.Crim.b_rule, dbo.Iris_Researchers.R_Name AS vendor, dbo.Crim.Crimenteredtime, dbo.Crim.CNTY_NO, 
                      dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, dbo.Crim.vendorid, dbo.Iris_Researchers.R_Delivery, dbo.Crim.IRIS_REC, 
                      dbo.Counties.A_County + ' , ' +  dbo.Counties.State as county
FROM dbo.Counties (NOLOCK)
INNER JOIN dbo.Crim(NOLOCK) ON dbo.Counties.CNTY_NO = dbo.Crim.CNTY_NO 
LEFT OUTER JOIN dbo.Iris_Researchers(NOLOCK) ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE  (dbo.Crim.vendorid IS NULL) 
  AND (dbo.Crim.IRIS_REC = 'yes') 
  and (crim.clear is null or crim.clear = 'R')
  and (datediff(mi,dbo.crim.crimenteredtime,getdate()) >= 1)
  AND dbo.Crim.IsHidden = 0 -- PK & VD:03/22 - Added Condition to get only Reportable crims
ORDER BY Crimenteredtime asc