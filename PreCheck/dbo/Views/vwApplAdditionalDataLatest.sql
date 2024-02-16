


/***********************************************
Author: Gaurav Bangia
Create Date: 3/15/2021
************************************************/
CREATE VIEW [dbo].[vwApplAdditionalDataLatest]
WITH SCHEMABINDING
AS

SELECT
	CTE.ApplAdditionalDataID,
	clno,
	cte.apno,
	ssn,
	CTE.Crim_SelfDisclosed,
	CTE.Empl_CanContactPresentEmployer,
	CTE.DataSource,
	CTE.DateCreated,
	CTE.SalaryRange,
	CTE.StateEmploymentOccur,
	cte.DateUpdated,
	CTE.ClientCertReceived,
	CTE.ClientCertBy,
	CTE.CityEmploymentOccur,
	CTE.CountyEmploymentOccur,
	CTE.CreateBy,
	CTE.ModifyBy
FROM 
dbo.ApplAdditionalData CTE WITH (NOLOCK)
INNER JOIN
(
	SELECT 
	r.APNO,
	LatestRecordId=MAX(R.ApplAdditionalDataID)
	FROM dbo.ApplAdditionalData R WITH (NOLOCK)
	GROUP BY R.apno
) L 
ON CTE.APNO=L.APNO  AND CTE.ApplAdditionalDataID=L.LatestRecordId





