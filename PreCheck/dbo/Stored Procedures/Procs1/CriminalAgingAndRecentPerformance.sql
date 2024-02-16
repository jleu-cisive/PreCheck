-- Alter Procedure CriminalAgingAndRecentPerformance
/*
Procedure Name : [dbo].[CriminalAgingAndRecentPerformance]
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [dbo].[CriminalAgingAndRecentPerformance]
*/

CREATE PROCEDURE [dbo].[CriminalAgingAndRecentPerformance]
AS
BEGIN

-- We are basically trying to find out the aging of the criminal records by App / Report and also by Pending Criminal Record
--

SELECT  A.APNO AS [Report Number], A.APDATE AS [Report Date], Q.A_County AS County, Q.State,C.CNTY_NO, A.First AS [Applicant First Name], A.Last AS [Applicant Last Name], X.Name AS [Client Name], C.Pub_Notes AS [Public Notes],
        IR.R_Name as [Vendor Name], C.deliverymethod as [Delivery Method], css.crimdescription as [Status],
		DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE, CURRENT_TIMESTAMP) AS [Elapsed Days Of Report], 
        DBO.ELAPSEDBUSINESSDAYS_2(C.CrimEnteredTime,CURRENT_TIMESTAMP) AS [Elapsed Days Of Search]
		INTO #temp1
FROM [dbo].[APPL] AS A (NOLOCK)
INNER JOIN [dbo].[Crim] AS C(NOLOCK) ON A.APNO = C.APNO
INNER JOIN [dbo].[TblCounties] AS Q(NOLOCK) ON C.CNTY_NO = Q.CNTY_NO
INNER JOIN [dbo].[Client] AS X(NOLOCK) ON A.CLNO = X.CLNO
INNER JOIN [dbo].[IRIS_Researchers] as IR on IR.R_id = C.VendorId
INNER JOIN [dbo].[Crimsectstat] as css on Css.crimsect = C.Clear
WHERE CLEAR = 'R'
  AND A.APDATE >= DATEADD(MONTH,-1,CURRENT_TIMESTAMP)
  AND IsHidden = 0
ORDER BY A.APNO DESC

-- Get the Average of all the Counties [i.e Grouped]. i.e Get a County and then all the available instances and get the Average.
--

SELECT CC.CNTY_NO, AVG(DBO.ELAPSEDBUSINESSDAYS_2(CC.CrimEnteredTime,CC.LAST_UPDATED)) AS [LAST 30 Days Performance Of Search]
		INTO #temp2
FROM CRIM AS CC WITH (NOLOCK) 
INNER JOIN dbo.TblCounties AS CCC WITH (NOLOCK) ON CC.CNTY_NO = CCC.CNTY_NO
where CC.IRISORDERED IS NOT NULL AND CC.LAST_UPDATED IS NOT NULL 
  AND IRISORDERED >= DATEADD(MONTH,-1,CURRENT_TIMESTAMP)
  AND IsHidden = 0
  AND CC.CNTY_NO IN (SELECT DISTINCT CNTY_NO FROM #temp1)
GROUP BY CC.CNTY_NO

-- Join two temp tables from above to get the output
SELECT [Report Number], [Applicant First Name], [Applicant Last Name],  [Report Date], [Client Name], [Public Notes], [Vendor Name], [Delivery Method], [Status], County, State, [Elapsed Days Of Report], [Elapsed Days Of Search], [LAST 30 Days Performance Of Search]
FROM #TEMP1 AS C 
INNER JOIN #TEMP2 AS CC ON C.CNTY_NO = CC.CNTY_NO
ORDER BY [Report Number], [Report Date]


DROP TABLE #temp1
DROP TABLE #temp2

END
