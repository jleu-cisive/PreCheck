﻿-- Alter Procedure Iris_PendingSearchByCounty

CREATE PROCEDURE [dbo].[Iris_PendingSearchByCounty] @cid int AS
BEGIN
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT     dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name AS vendor, dbo.Iris_Researchers.R_Delivery, 
                      dbo.Crim.CNTY_NO, dbo.Iris_Researchers.R_id AS vendorid, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
                      dbo.Crim.batchnumber, dbo.Crim.IRIS_REC, CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) AS Elapsed, 
                      dbo.TblCounties.A_County, dbo.TblCounties.State, dbo.TblCounties.A_County + ' , ' + dbo.TblCounties.State AS county
FROM         dbo.Appl INNER JOIN
                      dbo.Crim ON dbo.Appl.APNO = dbo.Crim.APNO INNER JOIN
                      dbo.TblCounties ON dbo.Crim.CNTY_NO = dbo.TblCounties.CNTY_NO LEFT OUTER JOIN
                      dbo.Iris_Researchers ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id
WHERE     (dbo.Crim.IRIS_REC = 'yes') AND (dbo.Crim.Clear = 'O') AND (dbo.Appl.ApStatus = 'p' OR
                      dbo.Appl.ApStatus = 'w')  and dbo.crim.cnty_no = @cid and  dbo.Crim.batchnumber IS not NULL
					  and dbo.Appl.CLNO not in (3468) and (dbo.crim.IsHidden = 0 ) -- Added this by Santosh on 06/24/13 to exclude BAD APPS and unused searches
GROUP BY dbo.Crim.status, dbo.Crim.Ordered, dbo.Iris_Researchers.R_Name, dbo.Iris_Researchers.R_Firstname, dbo.Iris_Researchers.R_Lastname, 
                      dbo.Crim.batchnumber, dbo.Iris_Researchers.R_id, dbo.Iris_Researchers.R_Delivery, dbo.Crim.County, dbo.Crim.IRIS_REC, dbo.Crim.CNTY_NO, 
                      dbo.TblCounties.A_County, dbo.TblCounties.State
--HAVING      (NOT (dbo.Crim.batchnumber IS NULL))
ORDER BY CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(dbo.Crim.Ordered, GETDATE())) desc;
END;
