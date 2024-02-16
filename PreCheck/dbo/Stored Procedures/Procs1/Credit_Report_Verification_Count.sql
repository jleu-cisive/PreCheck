/*  
Procedure Name : Credit_Report_Verification_Count  
Requested By: Misty Smallwood  
Developer: Deepak Vodethela
Modify by : Mainak Bhadra
Execution : [dbo].[Credit_Report_Verification_Count_test] '01/01/2022','01/31/2022'  
*/  
  
CREATE PROCEDURE [dbo].[Credit_Report_Verification_Count]  
(  
 @StartDate DateTime,  
 @EndDate DateTime  
)  
AS  
  
  
SELECT L.UserID, l.TableName component, L.ID AS APNO  
  INTO #tmpCreditRecords  
FROM dbo.Credit AS C(NOLOCK)  
INNER JOIN dbo.ChangeLog AS L(NOLOCK) ON C.APNO = L.ID  
WHERE C.SectStat in ('3','6')   
  AND C.RepType = 'C'   
  AND L.OldValue = '0'  
  AND L.NewValue IN ('3','6')  
  AND ((CONVERT(DATE, C.CreatedDate) >= CONVERT(DATE, @StartDate))   
  AND (CONVERT(DATE, C.CreatedDate) <= CONVERT(DATE, @EndDate)))  
ORDER BY C.CreatedDate DESC  
  
--SELECT * FROM #tmpCreditRecords  
  
SELECT UserID, count(component)  NoOfRecords  
FROM #tmpCreditRecords  
GROUP BY GROUPING SETS((UserId), ())  
  
DROP TABLE #tmpCreditRecords;