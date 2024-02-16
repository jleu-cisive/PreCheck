
------------------------------------------------------------------------------------------------
-- Created By - Radhika Dereddy on 10/14/2020
-- Requester - Pamela Esquero
-- EXEC [SJV_Overdue_StatusReport]
-- This Stored Procedure is used in [SJV_Overdue_StatusReport_Summary]
---------------------------------------------------------------------------------------------------
-- Modified by Cameron DeCook on 02/15/2023 HDT #83036 to correct Aging Assigned Date
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[SJV_Overdue_StatusReport]  AS


	SET NOCOUNT ON

    -- Insert statements for procedure here
	SELECT	A.Apno AS [Report Number],
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
			e.DateOrdered,
			[dbo].[ElapsedBusinessDays_2](A.ApDate,GETDATE()) AS [Aging of Report],
			[dbo].[ElapsedBusinessDays_2](E.DateOrdered,GETDATE()) AS [Aging Assigned Date],
			(CASE WHEN e.DNC = 1 THEN 'True' ELSE 'False' END) AS [Do Not Contact],
			wss.[description] AS WebStatus
		  INTO #tmpResult
	FROM Appl A WITH(NOLOCK)
	INNER JOIN Client C WITH(NOLOCK) ON A.Clno = C.Clno
	INNER JOIN Empl E WITH (NOLOCK) ON A.APNO = E.Apno AND E.SectStat='9' AND E.IsOnReport = 1 AND E.Investigator = 'SJV' AND E.OrderId IS NOT NULL --AND E.web_status = 0
	INNER JOIN refAffiliate RA WITH(NOLOCK) ON RA.AffiliateID = C.AffiliateID
	INNER JOIN Websectstat wss ON wss.code = E.web_status
	WHERE (A.ApStatus IN ('P','W')) 
	  AND a.CLNO NOT IN (2135,3468)
	  AND E.web_status IN (0,15,16,101,102) -- 10/11/2022 Pradip: added for ref call. removed in join
	  AND A.Investigator IS NOT NULL

	SELECT	Y.[Report Number],
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
			[DateOrdered],
			[Aging of Report],
			[Aging Assigned Date],
			[Do Not Contact],
			WebStatus,
			CASE
				WHEN LAG(X.EmplCount) OVER(PARTITION BY Y.[Report Number] ORDER BY X.EmplCount) = X.EmplCount THEN 0
				ELSE X.EmplCount
			END AS [Employment Counts]
	FROM #tmpResult AS Y
	INNER JOIN (SELECT [Report Number], SUM(COUNT([Report Number])) OVER(PARTITION BY [Report Number] ORDER BY [Report Number]) AS EmplCount FROM #tmpResult GROUP BY [Report Number]) AS X ON Y.[Report Number] = X.[Report Number]

	DROP TABLE #tmpResult

	SET ANSI_NULLS OFF
	SET QUOTED_IDENTIFIER OFF
