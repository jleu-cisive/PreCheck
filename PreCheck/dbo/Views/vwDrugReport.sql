
/*
Author: Gaurav Bangia
Date: 2/2/2018
Purpose: Returns latest pdf report 
*/
CREATE VIEW	[dbo].[vwDrugReport]
WITH SCHEMABINDING
AS
SELECT
	cte.tid,
	cte.PDFReport,
	CTE.Reason,
	CTE.AddedOn,
	CTE.ID
FROM dbo.OCHS_PDFReports CTE WITH (NOLOCK)
INNER JOIN
(
	SELECT
	R.TID,
	AddedOn=MAX(R.AddedOn)
	FROM dbo.OCHS_PDFReports R WITH (NOLOCK)
	GROUP BY R.TID
) L 
ON CTE.TID=L.TID  AND CTE.AddedOn=L.AddedOn
