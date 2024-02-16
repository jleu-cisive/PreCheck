 --=============================================   
--CreatedBy  CreatedDate    TicketNo		Description  
--YSharma	 07/Mar/2023    HDT #66159   HDT #66159 include DateOrdered Column and added filter for "SJV" Investigator
--           EXEC [dbo].[Employment_Overdue_Status_Report]
--============================================ 
    
Create PROCEDURE [dbo].[Qreport_SJV_Overdue_Status_Report_Details]  AS    
    
    
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
   e.DateOrdered,							-- Included for HDT #66159
   [dbo].[ElapsedBusinessDays_2](A.ApDate,GETDATE()) AS [Aging of Report],    
   --[dbo].[ElapsedBusinessDays_2](e.DateOrdered,GETDATE()) AS [Aging Assigned Date],   
   [dbo].[ElapsedBusinessDays_2](e.InvestigatorAssigned,GETDATE()) AS [Aging Assigned Date], -- Changed for HDT #84307  
   (CASE WHEN e.DNC = 1 THEN 'True' ELSE 'False' END) AS [Do Not Contact],    
   wss.[description] AS WebStatus    
    INTO #tmpResult    
 FROM dbo.Appl A WITH(NOLOCK)    
 INNER JOIN dbo.Client C WITH(NOLOCK) ON A.Clno = C.Clno    
 --INNER JOIN dbo.Empl E WITH (NOLOCK) ON A.APNO = E.Apno AND E.SectStat='9' AND E.IsOnReport = 1  
 INNER JOIN dbo.Empl E WITH (NOLOCK, INDEX(IX_Empl_SectStat_IsOnReport_Inc)) ON A.APNO = E.Apno AND E.SectStat='9' AND E.IsOnReport = 1
 INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON RA.AffiliateID = C.AffiliateID    
 INNER JOIN dbo.Websectstat wss ON wss.code = E.web_status    
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
   DateOrdered,							-- Included for HDT #66159
   CASE    
    WHEN LAG(X.EmplCount) OVER(PARTITION BY Y.[Report Number] ORDER BY X.EmplCount) = X.EmplCount THEN 0    
    ELSE X.EmplCount    
   END AS [Employment Counts]    
 FROM #tmpResult AS Y    
 INNER JOIN (SELECT [Report Number], SUM(COUNT([Report Number])) OVER(PARTITION BY [Report Number] ORDER BY [Report Number]) AS EmplCount FROM #tmpResult GROUP BY [Report Number]) AS X ON Y.[Report Number] = X.[Report Number]    
    Where Investigator='SJV'			-- Included for HDT #66159
 DROP TABLE #tmpResult    
    
 SET ANSI_NULLS OFF    
 SET QUOTED_IDENTIFIER OFF 