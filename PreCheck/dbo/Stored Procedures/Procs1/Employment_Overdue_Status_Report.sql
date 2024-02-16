
  
------------------------------------------------------------------------------------------------  
-- Created By - Radhika Dereddy on 05/14/2018  
-- Requester - Milton RObins  
-- EXEC [Employment_Overdue_Status_Report]  
-- This Stored Procedure is used in [Employment_Overdue_Status_Report_Summary]  
-- Modification by Humera Ahmed on 6/17/2019 for HDT - 53390 - Can you add the employer name to this Qreport, next to the Apno?  
-- Modified by: Deepak Vodethela  
-- Modified Date: 08/12/2019  
-- Description: Removed unwanted columns and fine tuned the Employment Counts Column and other columns of the report.   
-- Modified by Radhika Dereddy on 07/06/2020 to add the SJV OrderID  
-- Modified by Prasanna on 08/05/2020 to add the webstatus HDT#75870  
-- MOdified by Radhika Dereddy on 10/06/2020 to  correct the calculation of aging and assigned aging report  
-- Modified by Cameron DeCook on 02/15/2023 HDT #75893 correcting Assigned Aging Date  
-- Modified by Yashan Sharma on 02/24/2023 HDT #84307 Change the logic of Aging Assign Date (DateOrdered column replace to InvestigatorAssigned)
-- Modified by Arindam Mitra on 11/07/2023 HDT #116217 Added two new columns International and Emp State in the report
 ---------------------------------------------------------------------------------------------------  
  
CREATE PROCEDURE [dbo].[Employment_Overdue_Status_Report]  AS  
  
  
 SET NOCOUNT ON  
  
    -- Insert statements for procedure here  
 SELECT A.Apno AS [Report Number],  
   E.Employer,  
   e.Investigator,  
   A.ApDate,  
   A.[Last] AS [Last Name],   
   A.[First] AS [First Name],   
   A.ReopenDate AS [Reopen Date],  
   C.[Name] AS [Client Name],  
   C.AffiliateID,  
   RA.Affiliate,  
   e.OrderId AS [SJV OrderID],  
   [dbo].[ElapsedBusinessDays_2](A.ApDate,GETDATE()) AS [Aging of Report],  
   --[dbo].[ElapsedBusinessDays_2](e.DateOrdered,GETDATE()) AS [Aging Assigned Date], 
   [dbo].[ElapsedBusinessDays_2](e.InvestigatorAssigned,GETDATE()) AS [Aging Assigned Date], -- Changed for HDT #84307
   (CASE WHEN e.DNC = 1 THEN 'True' ELSE 'False' END) AS [Do Not Contact],  
   wss.[description] AS WebStatus
   , CASE WHEN E.IsIntl IS NULL THEN 'NO' WHEN E.IsIntl = 0 THEN 'NO' ELSE 'YES' END AS [International], --code added for HDT# 116217
   E.[state] AS [Emp State] --code added for HDT# 116217
    INTO #tmpResult  
 FROM Appl A WITH(NOLOCK)  
 INNER JOIN Client C WITH(NOLOCK) ON A.Clno = C.Clno  
 INNER JOIN Empl E WITH (INDEX(IX_Empl_SectStat_IsOnReport_Inc),NOLOCK) ON A.APNO = E.Apno AND E.SectStat='9' AND E.IsOnReport = 1 
 INNER JOIN refAffiliate RA WITH(NOLOCK) ON RA.AffiliateID = C.AffiliateID  
 INNER JOIN Websectstat wss ON wss.code = E.web_status  
 WHERE (A.ApStatus IN ('P','W'))   
   AND a.CLNO NOT IN (2135,3468)  
   AND A.Investigator IS NOT NULL  
  
 SELECT Y.[Report Number],  
   Employer,  
   Investigator,  
   Apdate,  
   [Last Name],  
   [First Name] ,  
   [Reopen Date],  
   [Client Name],  
   AffiliateID,  
   Affiliate,  
   [SJV OrderID],  
   [Aging of Report],  
   [Aging Assigned Date],  
   [Do Not Contact],  
   WebStatus,  
   CASE  
    WHEN LAG(X.EmplCount) OVER(PARTITION BY Y.[Report Number] ORDER BY X.EmplCount) = X.EmplCount THEN 0  
    ELSE X.EmplCount  
   END AS [Employment Counts],  
   International, --code added for HDT# 116217
   [Emp State] --code added for HDT# 116217
 FROM #tmpResult AS Y  
 INNER JOIN (SELECT [Report Number], SUM(COUNT([Report Number])) OVER(PARTITION BY [Report Number] ORDER BY [Report Number]) AS EmplCount FROM #tmpResult GROUP BY [Report Number]) AS X ON Y.[Report Number] = X.[Report Number]  
  
 DROP TABLE #tmpResult  
  
 SET ANSI_NULLS OFF  
 SET QUOTED_IDENTIFIER OFF  
