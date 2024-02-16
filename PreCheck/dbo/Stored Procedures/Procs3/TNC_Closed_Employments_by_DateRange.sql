-- =============================================  
-- Author: Arindam Mitra  
-- Requester: Pamela Esquero
-- Create date: 04/19/2023  
-- Description: To reconcile monthly billing for Thomas and Company with investigator1 as THORNGRE by date range.
-- multiple Client no to be separated by a colon. '0' indicates all client Id.
-- Execution: EXEC [dbo].[TNC_Closed_Employments_by_DateRange]  '03/01/2023','04/15/2023','0'  

-- =============================================  
CREATE PROCEDURE [dbo].[TNC_Closed_Employments_by_DateRange]  
 -- Add the parameters for the stored procedure here  
 @StartDate DateTime,  
 @EndDate DateTime,  
 @CLNO VARCHAR(500) = NULL
 
AS  

BEGIN
SET NOCOUNT ON  
  
  
 IF(@CLNO = '0' OR @CLNO IS NULL OR @CLNO = 'null')  
 BEGIN  
  SET @CLNO = '' 
 END  
  
 IF OBJECT_ID('tempdb..#tmpOverseas') IS NOT NULL DROP TABLE #tmpOverseas  
 IF OBJECT_ID('tempdb..#tmpSSN') IS NOT NULL DROP TABLE #tmpSSN  
 IF OBJECT_ID('tempdb..#Facility') IS NOT NULL DROP TABLE #Facility  
  

 SELECT distinct f.FacilityNum, f.IsOneHR, f.ParentEmployerID, f.EmployerID   
 INTO #Facility  
 FROM HEVN.dbo.Facility f  
  
 SELECT  A.CLNO AS [Client ID],   
   C.Name AS [Client Name],  
   RA.Affiliate,  
    A.Investigator, 
   CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS Null THEN 'N/A' END AS [IsOneHR],   
   A.APNO AS [Report Number],  
   A.SSN, 
   E.Employer AS Employer,   
   A.First AS [First Name],   
   A.Last AS [Last Name],   
   S.[Description] AS [Status],   
   isnull(sss.SectSubStatus, '') as [SubStatus],   
   format(A.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS[OriginalClose],  
   format(A.CompDate,'MM/dd/yyyy hh:mm tt') AS [Close Date],   
   A.UserID AS CAM,  
   e.Investigator AS [Investigator1],   
   CASE WHEN E.IsHidden = 0 THEN 'False' ELSE 'True' END AS [Is Hidden Report],  
   CASE WHEN e.IsOnReport = 0 THEN 'False' ELSE 'True' END AS [Is On Report],  
   E.Pub_Notes [Public Notes],  
   E.PRIV_NOTES AS [Private Notes]  
  INTO #tmpOverseas  
 FROM dbo.Appl AS A with(NOLOCK)  
 INNER JOIN dbo.Empl AS E with(NOLOCK) ON A.APNO = E.APNO  
 INNER JOIN dbo.SectStat AS S with(NOLOCK) ON E.SectStat = S.CODE  
 INNER JOIN dbo.Client AS C with(NOLOCK) ON A.CLNO = C.CLNO  
 INNER JOIN refAffiliate AS RA with(NOLOCK) ON C.AffiliateID = RA.AffiliateID  
 LEFT JOIN #Facility F with(NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum AND (c.WebOrderParentCLNO = F.ParentEmployerID OR C.WebOrderParentCLNO = F.EmployerID) --Added by Humera Ahmed on 5/11/2020 for HDT#72285  
 Left join dbo.SectSubStatus sss with(nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID  
 WHERE   
 E.Investigator='THORNGRE'
 AND A.OrigCompDate >= @StartDate    
   AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)  
   AND (ISNULL(@CLNO,'') = '' OR A.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))   
 ORDER BY A.CLNO, A.APNO 
  
   SELECT  A.SSN, COUNT(*) NoOfReports   
  into #tmpSSN  
 FROM dbo.Appl AS A WITH(NOLOCK)   
 INNER JOIN #tmpOverseas AS O with(nolock) ON A.SSN = O.SSN  
 GROUP BY A.SSN  
 HAVING COUNT(*) > 1   
  
  
   SELECT  [Client ID], [Client Name], Affiliate, [Report Number], Employer,     
    [First Name], [Last Name], 
    [Status],o.[SubStatus],
    [OriginalClose],[Close Date],  
    CAM,[Investigator1],[Is Hidden Report],[Is On Report],  
    [Public Notes],[Private Notes]  
 FROM #tmpOverseas AS O with(nolock)  
 LEFT OUTER JOIN #tmpSSN AS S with(nolock) ON O.SSN = S.SSN   
  
SET NOCOUNT OFF 

END