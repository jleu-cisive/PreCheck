  
-- =============================================  
-- Author: Deepak Vodethela  
-- Requester: Valerie K. Salazar  
-- Create date: 05/19/2017  
-- Description: To find out the overseas employments by date range  
-- Execution: EXEC [dbo].[Overseas_Employments_by_Clients_by_Date_Range_CA] '03/1/2016','05/19/2017','1619:2135:5751',''  
--     EXEC [dbo].[Overseas_Employments_by_Clients_by_Date_Range] '09/01/2019','09/30/2019','3115',0,0  
--     EXEC [dbo].[Overseas_Employments_by_Clients_by_Date_Range] '07/1/2019','07/19/2019','',''  
-- Updated 3/5/2019: Humera Ahmed - HDT - 47687 - Please add the unique Component TAT in a column to the Overseas Employment by Clients by Date Range report.    
-- Should reflect the TAT for the specific component displayed in the row.     
-- Modified by Radhika Dereddy on 03/22/2019 to Add OriginalClose date  
-- Modified by Humera Ahmed on 5/17/2019 to Add Public notes.  
-- Modified by Radhika dereddy on 07/23/2019 to add employment transferred column  
-- Modified BY Radhika Dereddy on 07/30/2019 to add AffiliateID as the parameter per Valerie  
-- Modified By Humera Ahmed on on 5/11/2020 for HDT#72285 - Please fix this q-report as it is running duplicate employments under the same report number.  
-- Modified By AmyLiu on 09/10/2020 for phase3 of project: IntranetModule: Status-SubSatus  
-- Modified BY James Norton on 04/07/2022  Created new _CA version to select by create data rather than original close.  
-- =============================================  
CREATE PROCEDURE [dbo].[Overseas_Employments_by_Clients_by_Date_Range_CA_test]  
 -- Add the parameters for the stored procedure here  
 @StartDate DateTime,  
 @EndDate DateTime,  
 @CLNO VARCHAR(500) = NULL,  
 --@AffiliateID int --code commented by Mainak for ticket id -55501
 @AffiliateIDs varchar(MAX) = '0'--code added by Mainak for ticket id -55501 
AS  
SET NOCOUNT ON  
  
 --declare @StartDate DateTime = '08/01/2020',  
 --@EndDate DateTime = '08/31/2020',  
 --@CLNO VARCHAR(500) = 0,  
 --@AffiliateID int = 230  
  
 IF(@CLNO = '0' OR @CLNO IS NULL OR @CLNO = 'null')  
 BEGIN  
  SET @CLNO = ''  
 END  

 
--code added by Mainak for ticket id -55501 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
--code added by Mainak for ticket id -55501 ends
  
 --Added by Humera Ahmed on 5/11/2020 for HDT#72285  
 IF OBJECT_ID('tempdb..#tmpOverseas') IS NOT NULL DROP TABLE #tmpOverseas  
 IF OBJECT_ID('tempdb..#tmpSSN') IS NOT NULL DROP TABLE #tmpSSN  
 IF OBJECT_ID('tempdb..#Facility') IS NOT NULL DROP TABLE #Facility  
  
 --Added by Humera Ahmed on 5/11/2020 for HDT#72285  
 SELECT distinct f.FacilityNum, f.IsOneHR, f.ParentEmployerID, f.EmployerID   
 INTO #Facility  
 FROM HEVN.dbo.Facility f  
  
 SELECT  A.CLNO AS [Client ID],   
   C.Name AS [Client Name],  
   RA.Affiliate,  
   CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS Null THEN 'N/A' END AS [IsOneHR],   
   A.Investigator,   
   A.APNO AS [Report Number],  
   A.SSN,  
   E.Employer AS Employer,   
   E.city AS [Emp City],  
   E.[state] AS [Emp State],  
   A.First AS [First Name],   
   A.Last AS [Last Name],   
   CASE WHEN E.IsIntl IS NULL THEN 'NO' WHEN E.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [International/Overseas],   
   dbo.elapsedbusinessdays_2(A.CreatedDate, A.CompDate) AS Turnaround,    
   dbo.elapsedbusinessdays_2(A.ReopenDate, A.CompDate) AS [ReOpen Turnaround],   
   dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS [Component TAT], --Added by Humera Ahmed on 3/5/2019 for HDT#47687  
   S.[Description] AS [Status],   
   isnull(sss.SectSubStatus, '') as [SubStatus],   
   format(A.ApDate,'MM/dd/yyyy hh:mm tt') AS [Received Date],   
   format(A.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS[OriginalClose],  
   format(A.CompDate,'MM/dd/yyyy hh:mm tt') AS [Close Date],   
   A.UserID AS CAM,  
   e.Investigator AS [Investigator1],   
   CASE WHEN E.IsHidden = 0 THEN 'False' ELSE 'True' END AS [Is Hidden Report],  
   CASE WHEN e.IsOnReport = 0 THEN 'False' ELSE 'True' END AS [Is On Report],  
   E.Pub_Notes [Public Notes],  
   E.PRIV_NOTES AS [Private Notes]  
  INTO #tmpOverseas  
 FROM dbo.Appl AS A(NOLOCK)  
 INNER JOIN dbo.Empl AS E(NOLOCK) ON A.APNO = E.APNO  
 INNER JOIN dbo.SectStat AS S(NOLOCK) ON E.SectStat = S.CODE  
 INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO  
 INNER JOIN refAffiliate AS RA(NOLOCK) ON C.AffiliateID = RA.AffiliateID  
 LEFT JOIN #Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum AND (c.WebOrderParentCLNO = F.ParentEmployerID OR C.WebOrderParentCLNO = F.EmployerID) --Added by Humera Ahmed on 5/11/2020 for HDT#72285  
 Left join dbo.SectSubStatus sss (nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID  
 WHERE   
 A.CreatedDate >= @StartDate    
   AND A.CreatedDate < DATEADD(DAY, 1, @EndDate)  
   AND (ISNULL(@CLNO,'') = '' OR A.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))  
  -- AND RA.AffiliateID = IIF(@AffiliateID =0, RA.AffiliateID, @AffiliateID)  --code commented by Mainak for ticket id -55501
   AND (@AffiliateIDs IS NULL OR RA.AffiliateID  IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Mainak for ticket id -55501
 ORDER BY A.CLNO, A.APNO  
  
  
 SELECT  A.SSN, COUNT(*) NoOfReports   
  into #tmpSSN  
 FROM dbo.Appl AS A WITH(NOLOCK)   
 INNER JOIN #tmpOverseas AS O ON A.SSN = O.SSN  
 GROUP BY A.SSN  
 HAVING COUNT(*) > 1  
  
  
 SELECT  [Client ID], [Client Name], Affiliate, O.IsOneHR, Investigator, [Report Number], Employer,   
    [Emp City], [Emp State], [First Name], [Last Name], [International/Overseas],  
    Turnaround,[ReOpen Turnaround],[Component TAT],[Status],o.[SubStatus], [Received Date],  
    [OriginalClose],[Close Date],  
    CAM,[Investigator1],[Is Hidden Report],[Is On Report],  
    [Public Notes],[Private Notes]  
 FROM #tmpOverseas AS O  
 LEFT OUTER JOIN #tmpSSN AS S ON O.SSN = S.SSN  
  
   
  
SET NOCOUNT OFF  