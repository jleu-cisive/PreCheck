-- =============================================  
-- Author:       Radhika Dereddy  
-- Create Date:  10/19/2021  
-- Description: HCA Initiative - Automated Inventory Report for C-Suite  
-- EXEC [dbo].[QualityControlLeadData_Schedule] '02/07/2024', '02/07/2024'  
-- =============================================  
CREATE PROCEDURE [dbo].[QualityControlLeadData_Schedule]  
@StartDate Date,  
@EndDate Date  
  
AS  
SET NOCOUNT ON  
SET ANSI_NULLS ON
  
DROP TABLE IF EXISTS #tempQCData  
DROP TABLE IF EXISTS #tempUSER  
DROP TABLE IF EXISTS #tmpAppl  
  
SET @EndDate = DATEADD(DAY,1,@EndDate)  
​  
SELECT DISTINCT userID   
INTO #tempUSER  
FROM dbo.APPL WITH (NOLOCK)   
WHERE      
 appl.ApStatus IN ('F','W')  
AND appl.CompDate BETWEEN @StartDate AND @EndDate  
AND UserID IS NOT NULL  
AND UserID NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '')  
ORDER BY UserID  
  
  
SELECT A.Apno, A.UserID INTO #tmpAppl      
 FROM dbo.Appl A WITH (NOLOCK)  
INNER JOIN dbo.Client c WITH(NOLOCK) ON a.clno =c.clno  
LEFT JOIN dbo.Crim  WITH (NOLOCK) on crim.apno= a.apno And Crim.IsHidden =0 and ( crim.clear is null or crim.clear in ('R','M','O','V','I','W','Z','D'))  
LEFT JOIN dbo.Civil WITH (NOLOCK) on civil.apno = a.apno AND ((Civil.Clear IS NULL) OR (Civil.Clear = 'O'))  
LEFT JOIN dbo.Credit WITH (NOLOCK) on (Credit.Apno = A.Apno) AND (Credit.SectStat = '0' OR Credit.SectStat = '9')  
LEFT JOIN  dbo.DL WITH (NOLOCK)  on (DL.Apno = A.Apno) AND (DL.SectStat = '0' OR DL.SectStat = '9')  
LEFT JOIN dbo.Empl WITH (NOLOCK) on  (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1 AND (Empl.SectStat = '0' OR Empl.SectStat = '9')  
LEFT JOIN dbo.Educat WITH (NOLOCK) on  (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '0' OR Educat.SectStat = '9')  
LEFT JOIN dbo.ProfLic WITH (NOLOCK) on (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat ='0' OR ProfLic.SectStat = '9')  
LEFT JOIN dbo.PersRef WITH (NOLOCK) on  (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '0' OR PersRef.SectStat = '9')  
LEFT JOIN dbo.Medinteg WITH (NOLOCK)  on  (Medinteg.Apno = A.Apno) AND (Medinteg.SectStat = '0' OR Medinteg.SectStat = '9')  
WHERE (A.ApStatus IN ('P','W'))  
AND ISNULL(A.Investigator, '') <> ''  
AND A.userid IS NOT null  
AND ISNULL(c.clienttypeid,-1) <> 15  
AND crim.CrimID is null  
AND civil.CivilID is null  
AND credit.apno is null  
AND DL.APNO is null  
AND empl.EmplID is null  
AND Educat.EducatID is null  
AND ProfLic.ProfLicID is null  
AND PersRef.PersRefID is null  
AND Medinteg.apno is null  
ORDER BY A.ApDate  
  
  
  
SELECT [UserID], [Total Closed where Assigned], TBF INTO #tempQCData  
FROM  
(  
 SELECT   
  'AUTO CLOSE' AS [UserID]   
  ,(SELECT COUNT(*) FROM dbo.ApplAutoCloseLog t (NOLOCK) WHERE ClosedOn BETWEEN @StartDate AND @EndDate) AS [Total Closed where Assigned]  
  ,0 AS TBF  
   
 UNION ALL  
  
 SELECT   
   U.UserID     
  ,ISNULL([Total Closed where Assigned],0) AS [Total Closed where Assigned]   
  ,ISNULL([TBF],0) AS [TBF]   
 FROM #tempUSER U  
 LEFT JOIN  
  (  
   SELECT COUNT(*)  AS [Total Closed where Assigned], a3.UserID  
   FROM dbo.Appl a3 WITH (NOLOCK)   
   WHERE a3.CompDate BETWEEN @StartDate AND @EndDate  
   GROUP BY a3.UserID  
  ) AS [Total Closed where Assigned] ON [Total Closed where Assigned].UserID = U.UserID  
 LEFT JOIN  
  (  
   SELECT COUNT(*) AS [TBF]  
    ,UserID  
   FROM #tmpAppl   
   GROUP BY UserID  
  ) AS [TBF] ON [TBF].UserID = U.UserID  
  
) A  
  
  
SELECT * FROM #tempQCData  