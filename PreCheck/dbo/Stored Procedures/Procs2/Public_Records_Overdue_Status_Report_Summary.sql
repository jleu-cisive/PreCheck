
------------------------------------------------------------------------------------------------
-- Created By - Radhika Dereddy on 03/13/2018
-- Requester - Misty Smallwood
-- Change Request - Clone the Overdue_Status_report to show some stats only pertaining to Public records which are in progress and Investigator is not null
-- ***** History of  the original report is below *******
-- It is broken down to elapsed date/percentage by affiliate. I only broke down the big 4 affiliates and then did "all other" for this example; 
-- qreport should provide a summary of all affiliates. Then I also need total volume/percentages by elapsed date. 
-- One by "affiliate" summary and the other a "high level" summary. 
-- both need to be based off of data from the Public Records Overdue Status Reporting so that we have accurate volumes. 
-- Modified Date :2/27/2020 - Sahithi Gangaraju , increased the length of first , last and middle columns in  @PublicRecords temp table 
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Public_Records_Overdue_Status_Report_Summary]  AS


SET NOCOUNT ON

--Step1: Execute the [Public_Records_Overdue_Status_Report] to have the accurate numbers, by create a new table



DECLARE @PublicRecords TABLE
(
	Apno int,
	ApStatus varchar(1),
	UserID varchar(8),
	Investigator varchar(8),
	Apdate datetime,
	Last varchar(50),
	First varchar(50),
	Middle varchar(50),
	ReopenDate datetime,
	ClientName varchar(100),
	Affiliate varchar(50),
	AffiliateID int,
	Elapsed decimal,
	InProgressReviewed varchar(10),
	CrimCount int
)

INSERT INTO @PublicRecords
EXEC [Public_Records_Overdue_Status_Report]

--select * from @publicRecords

DECLARE @CrimCountTemp TABLE
(
	AffiliateID int,
	CrimCount int,
	Elapsed decimal
)

INSERT INTO @CrimCountTemp
SELECT AffiliateID, CrimCount,Elapsed FROM @PublicRecords

--select * from @CrimCountTemp where AffiliateID in (147,159)

--Step 2: Create another table for Days
DECLARE @SectionTable TABLE 
( 
	NumberOfDays nvarchar(2),
	Order_seq int
) 

INSERT INTO @SectionTable (NumberOfDays, Order_seq)
VALUES ('7+',1),('6',2),('5',3),('4',4),('3',5),('2',6),('1',7)


--Step 3: Create a Temp table and get all the values for BIG4 and AllOther Affiliates
SELECT a.NumberOfDays,a.Order_seq, b.Affiliate, b.Total
INTO #tempBig5 
FROM @SectionTable a
INNER JOIN (
	SELECT (CASE WHEN AffiliateID in (147,159) THEN 'CHI'
	            WHEN AffiliateID in (4,5,294) THEN 'HCA'
				WHEN AffiliateID in (10,164,166) THEN 'Tenet'
				WHEN AffiliateID in (177) THEN 'UHS'
				WHEN AffiliateID in (229,230,231) THEN 'AdventHealth'
				WHEN AffiliateID in (249) THEN 'EVerifile'
				ELSE 'AllOther'  END) as Affiliate,
				(CASE WHEN Elapsed>=7 THEN '7+' else cast(Elapsed as nvarchar(2)) end) as Elapsed,
		Sum([CrimCount]) AS Total 
		FROM @CrimCountTemp
		GROUP BY (case WHEN AffiliateID in (147,159) THEN 'CHI'
	            WHEN AffiliateID in (4,5,294) THEN 'HCA'
				WHEN AffiliateID in (10,164,166) THEN 'Tenet'
				WHEN AffiliateID in (177) THEN 'UHS'
				WHEN AffiliateID in (229,230,231) THEN 'AdventHealth'
				WHEN AffiliateID in (249) THEN 'EVerifile'
				else 'AllOther' end),
		(CASE WHEN Elapsed >=7 THEN '7+' ELSE CAST(Elapsed as nvarchar(2)) end)) b
on a.NumberOfDays = b.Elapsed
ORDER by a.NumberOfDays desc,b.Affiliate asc

--select * from #tempBig5

--Step 4: Use the PIVOT function to get the totals
DECLARE @tempPivot TABLE 
( 
	NumberOfDays nvarchar(2),
	Order_seq int,
	HCA int,
	CHI int,
	Tenet int,
	UHS int,
	AdventHealth int,
	EVerifile int,
	AllOther int
) 
Insert into @tempPivot
SELECT NumberOfDays , Order_seq,
[HCA], [CHI], [Tenet], [UHS], [AdventHealth], [EVerifile], [ALLOTHER] 
FROM
(SELECT NumberOfDays,Order_seq,Affiliate, Coalesce(Total, 0) as Total
    FROM #tempBig5) AS SourceTable
PIVOT
(
sum(Total)
FOR Affiliate IN ([HCA], [CHI], [Tenet], [UHS],[AdventHealth],[EVerifile], [ALLOTHER])
) AS PivotTable
ORDER by NumberOfDays desc

--step 4b - Get the totals of all the CrimCount
DECLARE @TotalSumofCrimCount decimal(10,2)
SET @TotalSumofCrimCount = (Select Sum(HCA) + Sum(CHI) +Sum(Tenet) +Sum(UHS) + Sum(AdventHealth) + Sum(EVerifile) + Sum(AllOther) FROM @tempPivot)

--Step 5: Get the Totals and the Percentage fo the total volume
DECLARE @tempTotals TABLE 
( 
	NumberOfDays nvarchar(20),
	Order_seq int,
	HCA decimal(10,2),
	CHI decimal(10,2),
	Tenet decimal(10,2),
	UHS decimal(10,2),
	AdventHealth decimal(10,2),
	EVerifile decimal(10,2),
	AllOther decimal(10,2)
) 

INSERT INTO @tempTotals
SELECT * FROM 
(

	SELECT * FROM @tempPivot 

		UNION ALL

	SELECT 'Total' as  NumberOfDays, 8 as Order_seq, Sum(HCA) as [HCA], Sum(CHI) as [CHI], Sum(Tenet) as [Tenet], sum(UHS) as [UHS], Sum(AdventHealth) as [AdventHealth], Sum(EVerifile) as [EVerifile], sum(Allother) as [ALLOTHER] FROM @tempPivot

		UNION ALL

	SELECT '% of Total Volume' as  NumberOfDays, 9 as Order_seq,
	Cast( (Sum(HCA) / (@TotalSumofCrimCount)) * 100 as Decimal(10,2)) as 'HCA',
	Cast( (Sum(CHI) / (@TotalSumofCrimCount)) * 100 as Decimal(10,2)) as 'CHI',
	Cast( (Sum(Tenet) / (@TotalSumofCrimCount)) * 100 as Decimal(10,2)) as 'Tenet',
	Cast( (Sum(UHS) / (@TotalSumofCrimCount)) * 100 as Decimal(10,2)) as 'UHS',
	Cast( (Sum(AdventHealth) / (@TotalSumofCrimCount)) * 100 as Decimal(10,2)) as 'AdventHealth',
	Cast( (Sum(EVerifile) / (@TotalSumofCrimCount)) * 100 as Decimal(10,2)) as 'EVerifile',
	Cast( (Sum(AllOther) / (@TotalSumofCrimCount)) * 100 as Decimal(10,2)) as 'AllOther'	
	FROM @tempPivot

) A
	
--select * from @tempTotals

--Final result of the summary
SELECT NumberOfDays, HCA, CHI, Tenet, UHS, AdventHealth,EVerifile, AllOther,
(HCA + CHI + Tenet + UHS + AdventHealth + EVerifile + AllOther) as 'CriminalSearch',
CAST(ROUND(((HCA + CHI + Tenet + UHS + AdventHealth + EVerifile + AllOther)/(SELECT (HCA + CHI + Tenet + UHS + AdventHealth + EVerifile + AllOther) FROM @tempTotals WHERE NumberOfDays ='Total'))*100, 2) as Decimal(10,2)) as '% of Work'
FROM @tempTotals
ORDER BY Order_seq ASC

DROP TABLE #tempBig5

set ANSI_NULLS OFF


set QUOTED_IDENTIFIER OFF
