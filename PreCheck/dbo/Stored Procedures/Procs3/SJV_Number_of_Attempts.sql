-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 08/01/2020
-- Description:	<Description,,>
-- EXEC dbo.SJV_Number_of_Attempts '09/01/2020','09/10/2020', 0
-- =============================================
CREATE PROCEDURE [dbo].[SJV_Number_of_Attempts](
	@startdate datetime,
	@enddate datetime,
	@clno int
) 
as
BEGIN

	--select clno,apdate,* from dbo.Appl where apno = 5224949
	DROP TABLE IF EXISTS #tempVendorOrderLog
	DROP TABLE IF EXISTS #tempOrderAttempts
	DROP TABLE IF EXISTS #tmpEmpls
	DROP TABLE IF EXISTS #tmplClosedBySJV


		--Get the Employment between the date specified
		SELECT e.*,a.First,a.Last,A.SSN,a.ApDate
		into #tmpEmpls
		FROM Empl e 
		INNER JOIN dbo.Appl a ON e.APNO = a.APNO
		WHERE (a.ApDate BETWEEN @startdate AND @enddate)
		AND a.CLNO = IIF(@CLNO=0,a.CLNO,@CLNO)


		SELECT Max(cl.ID) AS ID
		--Max(cl.OldValue) AS OldValue,MAx(cl.NewValue) AS NewValue
		,Max(cl.ChangeDate) AS ChangeDate
		INTO #tmplClosedBySJV
		FROM dbo.ChangeLog cl 
		INNER JOIN #tmpEmpls e ON cl.ID = e.EmplID  
		WHERE TableName='Empl.Sectstat' 
		AND NewValue NOT IN ('0','9','A','H','R') AND Userid='SJV'
		GROUP BY cl.ID


		SELECT [Integration_VendorOrder_LogId]
			  ,[Integration_VendorOrderId]
			  ,[IsProcessed]
			  ,[StatusReceived]
			  ,l.[OrderId] AS OrderId
			  ,l.[CreatedDate]
			  ,[ProcessedDate]
			  ,[ErrorCount]
		INTO #tempVendorOrderLog
		  FROM [dbo].[Integration_VendorOrder_Log] l 
		  INNER JOIN #tmpEmpls e ON l.OrderId=e.OrderId

		SELECT 
			orderid,
			Count(OrderId) AS AttemptCount,
			MAx(CreatedDate) AS MostReceentAttempt  
		INTO #tempOrderAttempts
		FROM #tempVendorOrderLog
		GROUP BY OrderId


		SELECT e.Apno AS [Report Number]
			 ,e.OrderId  AS [SJV OrderId]
			 ,e.Employer AS [Employer Name]
			 ,e.First
			 ,e.Last
			 ,e.SSN
			 ,e.DateOrdered AS [Ordered Date]
			 ,vol.AttemptCount AS [Number of Attempts]
			 ,MostReceentAttempt AS [Date Last Attempted]
			 ,tm.ChangeDate as DateClosed
		FROM 
			dbo.Appl a
			INNER JOIN	#tmpEmpls e ON e.APNO = a.APNO
			INNER JOIN	#tmplClosedBySJV tm ON e.EmplID = tm.ID 
			INNER JOIN	#tempOrderAttempts  vol ON e.OrderId = vol.OrderId	
	
END		