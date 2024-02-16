  
/*------------------------------------------------------------------------------------------------  
-- Created By - Radhika Dereddy on 05/10/2018  
-- Requester - Chloe Cooper  

ModifiedBy		ModifiedDate	TicketNo	Description
Shashank Bhoi	12/23/2022		68621		#68621  Education Overdue Status Report Summary - Education column values are not matching with education education total  
											EXEC dbo.Education_Overdue_Status_Report_Summary
---------------------------------------------------------------------------------------------------*/
  
CREATE PROCEDURE [dbo].[Education_Overdue_Status_Report_Summary]  AS  
  
  
SET NOCOUNT ON  
  
--Step1: Execute the [Education_Overdue_Status_Report] to have the accurate numbers, by create a new table  
  
DECLARE @Education TABLE  
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
 EducatCount int  
)  
  
INSERT INTO @Education  
EXEC [Education_Overdue_Status_Report]  
  
--select * from @Education  
  
DECLARE @EducatCountTemp TABLE  
(  
 AffiliateID int,  
 EducatCount int,  
 Elapsed decimal  
)  
  
INSERT INTO @EducatCountTemp  
SELECT AffiliateID, EducatCount, Elapsed FROM @Education  
  
--select * from @Education where AffiliateID in (147,159)  
  
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
INNER JOIN (  
 SELECT (CASE WHEN AffiliateID in (147,159) THEN 'CHI'  
             WHEN AffiliateID in (4,5) THEN 'HCA'  
    WHEN AffiliateID in (10,164,166) THEN 'Tenet'  
    WHEN AffiliateID in (177) THEN 'UHS'  
    ELSE 'AllOther'  END) as Affiliate,  
    (CASE WHEN Elapsed>=7 THEN '7+' else cast(Elapsed as nvarchar(2)) end) as Elapsed,  
  Sum([EducatCount]) AS Total   
  FROM @EducatCountTemp  
  GROUP BY (case WHEN AffiliateID in (147,159) THEN 'CHI'  
             WHEN AffiliateID in (4,5) THEN 'HCA'  
    WHEN AffiliateID in (10,164,166) THEN 'Tenet'  
    WHEN AffiliateID in (177) THEN 'UHS'  
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
 AllOther int  
)   
Insert into @tempPivot  
SELECT NumberOfDays , Order_seq,  
--[HCA], [CHI], [Tenet], [UHS], [ALLOTHER]			--Code commented for 68621
ISNULL([HCA],0), ISNULL([CHI],0), ISNULL([Tenet],0), ISNULL([UHS],0), ISNULL([ALLOTHER],0)		--Code Added for 68621
FROM  
(SELECT NumberOfDays,Order_seq,Affiliate, Coalesce(Total, 0) as Total  
    FROM #tempBig4) AS SourceTable  
PIVOT  
(  
sum(Total)  
FOR Affiliate IN ([HCA], [CHI], [Tenet], [UHS], [ALLOTHER])  
) AS PivotTable  
ORDER by NumberOfDays desc  
  
  
  
--step 4b - Get the totals of all the EducatCount  
DECLARE @TotalSumofEducatCount decimal(10,2)  
SET @TotalSumofEducatCount = (Select Sum(HCA) + Sum(CHI) +Sum(Tenet) +Sum(UHS) + Sum(AllOther) FROM @tempPivot)  
  
  
--Step 5: Get the Totals and the Percentage fo the total volume  
DECLARE @tempTotals TABLE   
(   
 NumberOfDays nvarchar(20),  
 Order_seq int,  
 HCA decimal(10,2),  
 CHI decimal(10,2),  
 Tenet decimal(10,2),  
 UHS decimal(10,2),  
 AllOther decimal(10,2)  
)   
  
INSERT INTO @tempTotals  
SELECT * FROM   
(  
  
 SELECT * FROM @tempPivot   
  
  UNION ALL  
  
 SELECT 'Total' as  NumberOfDays, 8 as Order_seq, Sum(HCA) as [HCA], Sum(CHI) as [CHI], Sum(Tenet) as [Tenet], sum(UHS) as [UHS], sum(Allother) as [ALLOTHER] FROM @tempPivot  
  
  UNION ALL  
  
 SELECT '% of Total Volume' as  NumberOfDays, 9 as Order_seq,  
 Cast( (Sum(HCA) / (@TotalSumofEducatCount)) * 100 as Decimal(10,2)) as 'HCA',  
 Cast( (Sum(CHI) / (@TotalSumofEducatCount)) * 100 as Decimal(10,2)) as 'CHI',  
 Cast( (Sum(Tenet) / (@TotalSumofEducatCount)) * 100 as Decimal(10,2)) as 'Tenet',  
 Cast( (Sum(UHS) / (@TotalSumofEducatCount)) * 100 as Decimal(10,2)) as 'UHS',  
 Cast( (Sum(AllOther) / (@TotalSumofEducatCount)) * 100 as Decimal(10,2)) as 'AllOther'   
 FROM @tempPivot  
  
) A  
   
--select * from @tempTotals  
  
--Final result of the summary  
SELECT NumberOfDays, HCA, CHI, Tenet, UHS, AllOther,  
(HCA + CHI + Tenet + UHS + AllOther) as 'Education',  
CAST(ROUND(((HCA + CHI + Tenet + UHS + AllOther)/(SELECT (HCA + CHI + Tenet + UHS + AllOther) FROM @tempTotals WHERE NumberOfDays ='Total'))*100, 2) as Decimal(10,2)) as '% of Work'  
FROM @tempTotals  
ORDER BY Order_seq ASC  
  
  
  
set ANSI_NULLS OFF  
  
  
set QUOTED_IDENTIFIER OFF 
