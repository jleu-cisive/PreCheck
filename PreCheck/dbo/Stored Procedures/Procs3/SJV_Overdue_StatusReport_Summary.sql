
------------------------------------------------------------------------------------------------
-- Created By - Radhika Dereddy on 10/14/2020
-- Requester - Pamela Esquero
-- EXEC [SJV_Overdue_StatusReport_Summary]
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[SJV_Overdue_StatusReport_Summary]  AS


SET NOCOUNT ON

--Step1: Execute the [SJV_Overdue_StatusReport] to have the accurate numbers, by create a new table
	DECLARE @Employment TABLE
	(
		[Report Number] int,
		Employer varchar(200),
		Investigator varchar(8),
		Apdate datetime,
		[Last Name] varchar(20),
		[First Name] varchar(20),
		[Reopen Date] datetime,
		[Client Name] varchar(100),
		AffiliateID int,
		Affiliate varchar(50),
		[SJV OrderID] int,
		[DateOrdered] datetime,
		[Aging of Report] int,
		[Aging Assigned Date] int,
		[Do Not Contact] varchar(5),
		WebStatus varchar(70),
		[Employment Counts] int
	)


	INSERT INTO @Employment
	EXEC SJV_Overdue_StatusReport

	--select * from @Employment

	DECLARE @EmplCountTemp TABLE
	(
		[Report Number] int,
		AffiliateID int,
		[Employment Counts] int,
		[Aging Assigned Date] decimal
	)

	---- consider the  InvestigatorAssigned date to the Getdate as the Aging of Report
	INSERT INTO @EmplCountTemp
	SELECT [Report Number], AffiliateID, [Employment Counts], [Aging Assigned Date] FROM @Employment


	--Step 2: Create another table for Days
	DECLARE @SectionTable TABLE 
	( 
		NumberOfDays nvarchar(2),
		Order_seq int
	) 

	INSERT INTO @SectionTable (NumberOfDays, Order_seq)
	VALUES ('7+',1),('6',2),('5',3),('4',4),('3',5),('2',6),('1',7), ('0',8)


	--Step 3: Create a Temp table and get all the values for BIG4 and AllOther Affiliates
	SELECT a.NumberOfDays,a.Order_seq, b.Affiliate, b.Total
	INTO #tempBig4 
	FROM @SectionTable a
	INNER JOIN (
		SELECT (CASE WHEN AffiliateID in (147,159) THEN 'CHI'
					WHEN AffiliateID in (4,5) THEN 'HCA'
					WHEN AffiliateID in (10,164,166) THEN 'Tenet'
					WHEN AffiliateID in (177) THEN 'UHS'
					WHEN AffiliateID in (229,230,231) THEN 'Advent' 
					ELSE 'AllOther'  END) as Affiliate,
					(CASE WHEN [Aging Assigned Date]>=7 THEN '7+' else cast([Aging Assigned Date] as nvarchar(2)) end) as [Aging Assigned Date],
				Sum([Employment Counts]) AS Total 
			FROM @EmplCountTemp
			GROUP BY (case WHEN AffiliateID in (147,159) THEN 'CHI'
					WHEN AffiliateID in (4,5) THEN 'HCA'
					WHEN AffiliateID in (10,164,166) THEN 'Tenet'
					WHEN AffiliateID in (177) THEN 'UHS'
					WHEN AffiliateID in (229,230,231) THEN 'Advent' 
					else 'AllOther' end),
			(CASE WHEN [Aging Assigned Date] >=7 THEN '7+' ELSE CAST([Aging Assigned Date] as nvarchar(2)) end)) b
		on a.NumberOfDays = b.[Aging Assigned Date]
	ORDER by a.NumberOfDays desc,b.Affiliate asc


	--select * from #tempBig4


	--Step 4: Use the PIVOT function to get the totals
	DECLARE @tempPivot TABLE 
	( 
		NumberOfDays nvarchar(2),
		Order_seq int,
		HCA int,
		CHI int,
		Tenet int,
		UHS int,
		Advent int,
		AllOther int
	) 
	Insert into @tempPivot
	SELECT NumberOfDays , Order_seq,
	[HCA], [CHI], [Tenet], [UHS], [Advent], [ALLOTHER] 
	FROM
	(SELECT NumberOfDays,Order_seq,Affiliate, Coalesce(Total, 0) as Total
		FROM #tempBig4) AS SourceTable
	PIVOT
	(
	sum(Total)
	FOR Affiliate IN ([HCA], [CHI], [Tenet], [UHS],[Advent], [ALLOTHER]) 
	) AS PivotTable
	ORDER by NumberOfDays desc


--step 4b - Get the totals of all the EmplCount
	DECLARE @TotalSumofEmplCount decimal(10,2)
	SET @TotalSumofEmplCount = (Select Sum(HCA) + Sum(CHI) +Sum(Tenet) +Sum(UHS) + Sum(Advent)+ Sum(AllOther) FROM @tempPivot) -- Modified by Humera Ahmed for HDT#52264


	--Step 5: Get the Totals and the Percentage fo the total volume
	DECLARE @tempTotals TABLE 
	( 
		NumberOfDays nvarchar(20),
		Order_seq int,
		HCA decimal(10,2),
		CHI decimal(10,2),
		Tenet decimal(10,2),
		UHS decimal(10,2),
		Advent decimal(10,2), 
		AllOther decimal(10,2)
	) 

	INSERT INTO @tempTotals
	SELECT * FROM 
	(

		SELECT * FROM @tempPivot 

			UNION ALL

		SELECT 'Total' as  NumberOfDays, 8 as Order_seq, Sum(HCA) as [HCA], Sum(CHI) as [CHI], Sum(Tenet) as [Tenet], sum(UHS) as [UHS], sum(Advent) as [Advent], sum(Allother) as [ALLOTHER] FROM @tempPivot

			UNION ALL

		SELECT '% of Total Volume' as  NumberOfDays, 9 as Order_seq,
		Cast( (Sum(HCA) / (@TotalSumofEmplCount)) * 100 as Decimal(10,2)) as 'HCA',
		Cast( (Sum(CHI) / (@TotalSumofEmplCount)) * 100 as Decimal(10,2)) as 'CHI',
		Cast( (Sum(Tenet) / (@TotalSumofEmplCount)) * 100 as Decimal(10,2)) as 'Tenet',
		Cast( (Sum(UHS) / (@TotalSumofEmplCount)) * 100 as Decimal(10,2)) as 'UHS',
		Cast( (Sum(Advent) / (@TotalSumofEmplCount)) * 100 as Decimal(10,2)) as 'Advent', 
		Cast( (Sum(AllOther) / (@TotalSumofEmplCount)) * 100 as Decimal(10,2)) as 'AllOther'	
		FROM @tempPivot

	) A
	
	--select * from @tempTotals

	--Final result of the summary
	SELECT NumberOfDays, HCA, CHI, Tenet, UHS, Advent, AllOther,
	(isnull(HCA,0) + isnull(CHI,0) + isnull(Tenet,0) + isnull(UHS,0) + isnull(Advent,0) + isnull(AllOther,0)) as 'Employment',
	CAST(ROUND(((isnull(HCA,0) + isnull(CHI,0) + isnull(Tenet,0) + isnull(UHS,0) + isnull(Advent,0) + isnull(AllOther,0))/(SELECT (isnull(HCA,0) + isnull(CHI,0) + isnull(Tenet,0) + isnull(UHS,0) + isnull(Advent,0) + isnull(AllOther,0)) FROM @tempTotals WHERE NumberOfDays ='Total'))*100, 2) as Decimal(10,2)) as '% of Work'
	FROM @tempTotals
	ORDER BY Order_seq ASC



	set ANSI_NULLS OFF


	set QUOTED_IDENTIFIER OFF
