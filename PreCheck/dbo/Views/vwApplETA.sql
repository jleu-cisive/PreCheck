
/***************************************************
Author: Gaurav Bangia
Create Date: 3/15/2021
Description: View provides the rollup ETA date 
value at the APNO level
***************************************************/

CREATE VIEW [dbo].[vwApplETA]
WITH SCHEMABINDING
AS

SELECT
	CTE.APNO,
	CTE.ETADate
FROM 
dbo.ApplSectionsETA CTE WITH (NOLOCK)
INNER JOIN
(
	SELECT 
	eta.Apno,
	ApplETA=MAX(eta.ETADate)
	FROM dbo.ApplSectionsETA eta WITH (NOLOCK)
	GROUP BY eta.apno
) L 
ON CTE.APNO=L.APNO  AND CTE.ETADate= L.ApplETA
GROUP BY cte.Apno,cte.ETADate






