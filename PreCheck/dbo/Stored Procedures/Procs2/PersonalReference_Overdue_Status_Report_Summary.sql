
------------------------------------------------------------------------------------------------
-- Created By - Radhika Dereddy on 05/15/2018
-- Requester - Milton RObins
-- Modified By AmyLiu on 03/01/2019: HDT47374 fix the issue of uncorrect count
-- Modified by Humera Ahmed on 5/16/2019 for HDT#52264
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[PersonalReference_Overdue_Status_Report_Summary]  AS


SET NOCOUNT ON

--Step1: Execute the [PersonalReference_Overdue_Status_Report] to have the accurate numbers, by create a new table

DECLARE @PersonalReference TABLE
(
	Apno int,
	ApStatus varchar(1),
	UserID varchar(8),
	Investigator varchar(8),
	Apdate datetime,
	Last varchar(20),
	First varchar(20),
	Middle varchar(20),
	ReopenDate datetime,
	ClientName varchar(100),
	Affiliate varchar(50),
	AffiliateID int,
	Elapsed decimal,
	InProgressReviewed varchar(10),
	PersRefCount int
)

INSERT INTO @PersonalReference
EXEC [PersonalReference_Overdue_Status_Report]

--select * from @PersonalReference

DECLARE @PersonalReferenceCountTemp TABLE
(
	AffiliateID int,
	PersRefCount int,
	Elapsed decimal
)

INSERT INTO @PersonalReferenceCountTemp
SELECT AffiliateID, PersRefCount, Elapsed FROM @PersonalReference

--select * from @PersonalReference where AffiliateID in (147,159)

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
INTO #tempBig4 
FROM @SectionTable a
LEFT JOIN (
	SELECT (CASE WHEN AffiliateID in (147,159) THEN 'CHI'
	            WHEN AffiliateID in (4,5) THEN 'HCA'
				WHEN AffiliateID in (10,164,166) THEN 'Tenet'
				WHEN AffiliateID in (177) THEN 'UHS'
				WHEN AffiliateID in (229,230,231) THEN 'Advent' -- Modified by Humera Ahmed for HDT#52264
				ELSE 'AllOther'  END) as Affiliate,
				(CASE WHEN Elapsed>=7 THEN '7+' else cast(Elapsed as nvarchar(2)) end) as Elapsed,
		Sum([PersRefCount]) AS Total 
		FROM @PersonalReferenceCountTemp
		GROUP BY (case WHEN AffiliateID in (147,159) THEN 'CHI'
	            WHEN AffiliateID in (4,5) THEN 'HCA'
				WHEN AffiliateID in (10,164,166) THEN 'Tenet'
				WHEN AffiliateID in (177) THEN 'UHS'
				WHEN AffiliateID in (229,230,231) THEN 'Advent' -- Modified by Humera Ahmed for HDT#52264
				else 'AllOther' end),
		(CASE WHEN Elapsed >=7 THEN '7+' ELSE CAST(Elapsed as nvarchar(2)) end)) b
on a.NumberOfDays = b.Elapsed
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
	Advent int, -- Modified by Humera Ahmed on 5/16/2019 for HDT#52264
	AllOther int
) 
Insert into @tempPivot
SELECT NumberOfDays , Order_seq,
[HCA], [CHI], [Tenet], [UHS],[Advent], [ALLOTHER]  -- Modified by Humera Ahmed on 5/16/2019 for HDT#52264
FROM
(SELECT NumberOfDays,Order_seq,Affiliate, Coalesce(Total, 0) as Total
    FROM #tempBig4) AS SourceTable
PIVOT
(
sum(Total)
FOR Affiliate IN ([HCA], [CHI], [Tenet], [UHS], [Advent], [ALLOTHER]) -- Modified by Humera Ahmed on 5/16/2019 for HDT#52264
) AS PivotTable
ORDER by NumberOfDays desc

--select * from @tempPivot

--step 4b - Get the totals of all the PersRefCount
DECLARE @TotalSumofPersRefCount decimal(10,2)
SET @TotalSumofPersRefCount = (Select COALESCE(SUM(HCA),0) + COALESCE(Sum(CHI),0) + COALESCE(Sum(Tenet),0) + COALESCE(Sum(UHS),0) + COALESCE(Sum(Advent),0) + COALESCE(Sum(AllOther),0) FROM @tempPivot)


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

	SELECT 'Total' as  NumberOfDays, 8 as Order_seq, COALESCE(SUM(HCA),0) as [HCA], COALESCE(Sum(CHI),0) as [CHI], COALESCE(Sum(Tenet),0)  as [Tenet], COALESCE(Sum(UHS),0)  as [UHS], COALESCE(Sum(Advent),0)  as [UHS], COALESCE(Sum(AllOther),0) as [ALLOTHER] FROM @tempPivot

		UNION ALL

	SELECT '% of Total Volume' as  NumberOfDays, 9 as Order_seq,
	Cast( (COALESCE(SUM(HCA),0) / (@TotalSumofPersRefCount)) * 100 as Decimal(10,2)) as 'HCA',
	Cast( (COALESCE(Sum(CHI),0) / (@TotalSumofPersRefCount)) * 100 as Decimal(10,2)) as 'CHI',
	Cast( (COALESCE(Sum(Tenet),0) / (@TotalSumofPersRefCount)) * 100 as Decimal(10,2)) as 'Tenet',
	Cast( (COALESCE(Sum(UHS),0) / (@TotalSumofPersRefCount)) * 100 as Decimal(10,2)) as 'UHS',
	Cast( (COALESCE(Sum(Advent),0) / (@TotalSumofPersRefCount)) * 100 as Decimal(10,2)) as 'Advent',
	Cast( (COALESCE(Sum(AllOther),0) / (@TotalSumofPersRefCount)) * 100 as Decimal(10,2)) as 'AllOther'	
	FROM @tempPivot

) A
	
--select * from @tempTotals

--Final result of the summary
SELECT NumberOfDays, HCA, CHI, Tenet, UHS, Advent, AllOther,
(ISNUll(HCA, 0) + ISNUll(CHI, 0) + ISNUll(Tenet,0) + ISNULL(UHS,0) + ISNULL(Advent,0) + ISNULL(AllOther, 0)) as 'PersonalReference',
CAST(ROUND(((ISNUll(HCA, 0) +  ISNUll(CHI, 0) + ISNUll(Tenet,0) + ISNULL(UHS,0) + ISNULL(Advent,0) + ISNULL(AllOther, 0))/(SELECT (ISNUll(HCA, 0) + ISNUll(CHI, 0) + ISNUll(Tenet,0) + ISNULL(UHS,0) + ISNULL(Advent,0) + ISNULL(AllOther, 0)) FROM @tempTotals WHERE NumberOfDays ='Total'))*100, 2) as Decimal(10,2)) as '% of Work'
FROM @tempTotals
ORDER BY Order_seq ASC




set ANSI_NULLS OFF


set QUOTED_IDENTIFIER OFF
