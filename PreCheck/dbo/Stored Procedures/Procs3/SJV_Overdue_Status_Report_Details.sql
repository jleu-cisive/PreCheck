---- =============================================
---- Author:		<Sunil Mandal>
---- Create date: <10-Oct-2022>
---- Description:	<#66159 SJV Overdue Status Report Details>
---- =============================================
/*
Exec [dbo].[SJV_Overdue_Status_Report_Details]

*/
Create PROC [dbo].[SJV_Overdue_Status_Report_Details]  

AS 
BEGIN

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
			e.OrderId as [SJV OrderID],
			[dbo].[ElapsedBusinessDays_2](A.ApDate,GETDATE()) AS [Aging of Report],
			[dbo].[ElapsedBusinessDays_2](e.InvestigatorAssigned,GETDATE()) AS [Aging Assigned Date],
			(CASE WHEN e.DNC = 1 THEN 'True' ELSE 'False' END) AS [Do Not Contact],
			wss.[description] as WebStatus,			
			Convert(datetime2,NULL) As OrderDate			
		  INTO #tmpResult
	FROM Appl A with(nolock)
	INNER JOIN Client C with(nolock) ON A.Clno = C.Clno
	INNER JOIN Empl E WITH (nolock) ON A.APNO = E.Apno AND E.SectStat='9' AND E.IsOnReport = 1
	INNER JOIN refAffiliate RA with(nolock) on RA.AffiliateID = C.AffiliateID
	INNER JOIN Websectstat wss on wss.code = E.web_status	
	WHERE (A.ApStatus IN ('P','W')) 
	  AND a.CLNO NOT IN (2135,3468)
	  AND A.Investigator IS NOT NULL

Select APNO,Max(DateOrdered) As DateOrdered INTO #DateOrdered from Empl 
Where SectStat='9' AND IsOnReport = 1 Group By APNO

Update TR
Set TR.OrderDate = Em.DateOrdered
From #tmpResult TR
Inner Join #DateOrdered Em ON TR.[Report Number] = Em.APNO




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
			[Aging of Report],
			[Aging Assigned Date],
			[Do Not Contact],
			WebStatus,
			OrderDate,
			CASE
				WHEN LAG(X.EmplCount) OVER(PARTITION BY Y.[Report Number] ORDER BY X.EmplCount) = X.EmplCount THEN 0
				ELSE X.EmplCount
			END AS [Employment Counts]
	FROM #tmpResult AS Y
	INNER JOIN (SELECT [Report Number], SUM(COUNT([Report Number])) OVER(PARTITION BY [Report Number] ORDER BY [Report Number]) AS EmplCount FROM #tmpResult GROUP BY [Report Number]) AS X ON Y.[Report Number] = X.[Report Number]

	DROP TABLE #tmpResult

End
