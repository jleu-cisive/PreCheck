/*
Procedure Name : AI_Activity_Report_By_Hour
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : EXEC [AI_Activity_Report_By_Hour]
*/

CREATE PROCEDURE [dbo].[AI_Activity_Report_By_Hour]
AS

IF OBJECT_ID('tempdb..#ReviewedFromGetNextLog') IS NOT NULL
BEGIN
    DROP TABLE #ReviewedFromGetNextLog
END

IF OBJECT_ID('tempdb..#ReviewedFromChangeLog') IS NOT NULL
BEGIN
    DROP TABLE #ReviewedFromChangeLog
END

IF OBJECT_ID('tempdb..#InvestigatorFromAppl') IS NOT NULL
BEGIN
    DROP TABLE #InvestigatorFromAppl
END

IF OBJECT_ID('tempdb..#TotalReviewsByInvestigator') IS NOT NULL
BEGIN
    DROP TABLE #TotalReviewsByInvestigator
END

IF OBJECT_ID('tempdb..#InvestigatorFromAppl') IS NOT NULL
BEGIN
    DROP TABLE #InvestigatorFromAppl
END

-- Get Data from ApplGetNextLog
SELECT  UserName AS Investigator,
		CreatedDate AS ReviewDate,
		DATEPART(HOUR, CreatedDate) AS [Hour],
		COUNT(*) AS	NoOfReviews 
		INTO #ReviewedFromGetNextLog
FROM dbo.ApplGetNextLog WITH(Nolock)
WHERE CreatedDate > DATEADD(HOUR,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))
 AND CreatedDate <= DATEADD(HOUR,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))
GROUP BY UserName,
		 CreatedDate,
		 DATEPART(HOUR, CreatedDate)
ORDER BY UserName,
		 DATEPART(HOUR, CreatedDate) ASC

--SELECT * FROM #ReviewedFromGetNextLog ORDER BY ReviewDate DESC

-- Get Data from ChangeLog
SELECT	Newvalue AS Investigator,
		ChangeDate AS ReviewDate,
		DATEPART(HOUR, ChangeDate) AS [Hour],
		COUNT(*) AS	NoOfReviews 
		INTO #ReviewedFromChangeLog
FROM dbo.ChangeLog WITH(Nolock)
WHERE ChangeDate > DATEADD(HOUR,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))
  AND ChangeDate< = DATEADD(HOUR,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))
  AND TableName like 'Appl.Investigator' 
  AND OldValue = '' 
GROUP BY Newvalue,
		 ChangeDate,
		 DATEPART(HOUR, ChangeDate)
ORDER BY Newvalue,
		 DATEPART(HOUR, ChangeDate) ASC

--SELECT * FROM #ReviewedFromChangeLog ORDER BY ReviewDate DESC

-- Combine Date from GetNextLog and ChangeLog Values
SELECT	Investigator, 
		[Hour], 
		COUNT(*) AS TotalReviewsByHour
		INTO #TotalReviewsByInvestigator
FROM
(
	SELECT Investigator, [Hour], NoOfReviews FROM #ReviewedFromGetNextLog
	UNION ALL
	SELECT Investigator, [Hour], NoOfReviews FROM #ReviewedFromChangeLog
) AS TotalReviewsByInv
GROUP BY Investigator,
		 [Hour]

--SELECT * FROM #TotalReviewsByInvestigator ORDER BY Investigator, [Hour] ASC

--SELECT * FROM #ReviewedFromGetNextLog WHERE Investigator = 'Agonzale'
--SELECT * FROM #ReviewedFromChangeLog WHERE Investigator = 'Agonzale'

-- Get Data from Appl - Masterlist of Investigators
SELECT	Investigator
		INTO #InvestigatorFromAppl
FROM APPL WITH(Nolock)
WHERE COALESCE(Investigator,'') <> '' 
  AND Last_Updated >= DATEADD(HOUR,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME))  --@StartDate 
  AND Last_Updated <= DATEADD(HOUR,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME)) --DATEADD(S,-1,DATEADD(D,1,@EndDate))
GROUP BY Investigator

--SELECT * FROM #InvestigatorFromAppl ORDER BY Investigator DESC

-- Get Final Aging Report by Hour [Totals By Rows and Columns]
SELECT	COALESCE(I.Investigator,'Total' ) AS Investigator,
		SUM(CASE WHEN [Hour] = '6' THEN TotalReviewsByHour ELSE 0 END) [6:00 am - 6:59 am],
		SUM(CASE WHEN [Hour] = '7' THEN TotalReviewsByHour ELSE 0 END) [7:00 am - 7:59 am],
		SUM(CASE WHEN [Hour] = '8' THEN TotalReviewsByHour ELSE 0 END) [8:00 am - 8:59 am],
		SUM(CASE WHEN [Hour] = '9' THEN TotalReviewsByHour ELSE 0 END) [9:00 am - 9:59 am],
		SUM(CASE WHEN [Hour] = '10' THEN TotalReviewsByHour ELSE 0 END) [10:00 am - 10:59 am],
		SUM(CASE WHEN [Hour] = '11' THEN TotalReviewsByHour ELSE 0 END) [11:00 am - 11:59 am],
		SUM(CASE WHEN [Hour] = '12' THEN TotalReviewsByHour ELSE 0 END) [12:00 pm - 12:59 pm],
		SUM(CASE WHEN [Hour] = '13' THEN TotalReviewsByHour ELSE 0 END) [1:00 pm - 1:59 pm],
		SUM(CASE WHEN [Hour] = '14' THEN TotalReviewsByHour ELSE 0 END) [2:00 pm - 2:59 pm],
		SUM(CASE WHEN [Hour] = '15' THEN TotalReviewsByHour ELSE 0 END) [3:00 pm - 3:59 pm],
		SUM(CASE WHEN [Hour] = '16' THEN TotalReviewsByHour ELSE 0 END) [4:00 pm - 4:59 pm],
		SUM(CASE WHEN [Hour] = '17' THEN TotalReviewsByHour ELSE 0 END) [5:00 pm - 5:59 pm],
		SUM(CASE WHEN [Hour] = '18' THEN TotalReviewsByHour ELSE 0 END) [6:00 pm - 6:59 pm],
		SUM(CASE WHEN [Hour] = '19' THEN TotalReviewsByHour ELSE 0 END) [7:00 pm - 7:59 pm],
		SUM(TotalReviewsByHour) AS TotalReviewsByInvestigator
FROM #TotalReviewsByInvestigator AS T WITH(NOLOCK)
INNER JOIN #InvestigatorFromAppl AS I ON I.Investigator = T.Investigator
GROUP BY ROLLUP(I.Investigator)
ORDER BY GROUPING(I.Investigator)



/*

-- First SP - With Oasis Table

IF OBJECT_ID('tempdb..#AIActivityByHour') IS NOT NULL
BEGIN
    DROP TABLE #AIActivityByHour
END

-- Get number of Reviews done by Investgator 
SELECT	Investigator,
		DATEPART(hh, AIMICreatedDate) AS [Hour], 
		COUNT(*) AS	NoOfReviews
		INTO #AIActivityByHour
FROM Metastorm9_2.dbo.Oasis WITH(NOLOCK)
WHERE Investigator IS NOT NULL
  AND AIMICreatedDate >= DATEADD(HOUR,6,CAST(CAST(GETDATE() AS DATE) AS DATETIME)) 
  AND AIMICreatedDate < DATEADD(HOUR,20,CAST(CAST(GETDATE() AS DATE) AS DATETIME))
GROUP BY Investigator,
		 DATEPART(hh, AIMICreatedDate)
ORDER BY Investigator,
		 DATEPART(hh, AIMICreatedDate) ASC

--SELECT * FROM #AIActivityByHour ORDER BY Investigator, Hour ASC

-- Generate Activity Report By Hour for each Investigator
SELECT	Investigator,
		MAX(CASE WHEN [Hour] = '6' THEN NoOfReviews ELSE 0 END) [6:00 am - 6:59 am],
		MAX(CASE WHEN [Hour] = '7' THEN NoOfReviews ELSE 0 END) [7:00 am - 7:59 am],
		MAX(CASE WHEN [Hour] = '8' THEN NoOfReviews ELSE 0 END) [8:00 am - 8:59 am],
		MAX(CASE WHEN [Hour] = '9' THEN NoOfReviews ELSE 0 END) [9:00 am - 9:59 am],
		MAX(CASE WHEN [Hour] = '10' THEN NoOfReviews ELSE 0 END) [10:00 am - 10:59 am],
		MAX(CASE WHEN [Hour] = '11' THEN NoOfReviews ELSE 0 END) [11:00 am - 11:59 am],
		MAX(CASE WHEN [Hour] = '12' THEN NoOfReviews ELSE 0 END) [12:00 pm - 12:59 pm],
		MAX(CASE WHEN [Hour] = '13' THEN NoOfReviews ELSE 0 END) [1:00 pm - 1:59 pm],
		MAX(CASE WHEN [Hour] = '14' THEN NoOfReviews ELSE 0 END) [2:00 pm - 2:59 pm],
		MAX(CASE WHEN [Hour] = '15' THEN NoOfReviews ELSE 0 END) [3:00 pm - 3:59 pm],
		MAX(CASE WHEN [Hour] = '16' THEN NoOfReviews ELSE 0 END) [4:00 pm - 4:59 pm],
		MAX(CASE WHEN [Hour] = '17' THEN NoOfReviews ELSE 0 END) [5:00 pm - 5:59 pm],
		MAX(CASE WHEN [Hour] = '18' THEN NoOfReviews ELSE 0 END) [6:00 pm - 6:59 pm],
		MAX(CASE WHEN [Hour] = '19' THEN NoOfReviews ELSE 0 END) [7:00 pm - 7:59 pm],
		SUM(NoOfReviews) AS TotalReviews
FROM #AIActivityByHour WITH(NOLOCK)
GROUP BY Investigator
ORDER BY Investigator

*/