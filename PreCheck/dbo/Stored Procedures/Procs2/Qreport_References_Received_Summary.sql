-- =============================================  
-- Author:  Humera Ahmed  
-- Create date: 2/24/2020  
-- Description: Qreport that is providing details summary of the Qreport References Received  
-- EXEC [dbo].[Qreport_References_Received_Summary] '4/23/2019','4/23/2019'  
-- =============================================  
-- Modify by : Yashan Sharma
-- Modify Date : 17-Aug-2022
-- Desc : The logic change as per requestor's requirement HDT #31930 (Refernce given report "Component count by Date range summary QReport")
--        Also Added one row in the top which will show TOTAL REF COUNT
-- EXEC [dbo].[Qreport_References_Received_Summary] '08/08/2022','08/08/2022'
-- =============================================
CREATE PROCEDURE [dbo].[Qreport_References_Received_Summary] 
@StartDate Date = '',  
 @EndDate Date = ''  
AS  
BEGIN
--Declare @StartDate Datetime 
--Declare @EndDate Datetime 
--Set @StartDate = '08/08/2022'
--Set @EndDate = '08/08/2022'

DROP TABLE IF exists #tmpCounts

Select Cnt.Apno [Report Number]
, Cnt.Referencecount AS [Number of References]
, c.Name [Client Name]
, c.AffiliateID 
, ra.Affiliate [Affiliate Name] 
	INTO #tmpCounts
 From 
	(
		SELECT apno
			,count(1) Referencecount 
		FROM PersRef(NOLOCK)
		WHERE PersRef.IsOnReport = 1
			AND persref.ishidden = 0
			AND persref.createddate BETWEEN @StartDate
				AND DateAdd(d, 1, @EndDate)
		GROUP BY apno
	) Cnt
LEFT JOIN Appl A On Cnt.APNO=A.APNO
INNER JOIN Client C On A.ClNO=C.CLNO
INNER JOIN dbo.refAffiliate ra ON c.AffiliateID = ra.AffiliateID

-- Adding on more row in the output for total References Count 
	SELECT NULL AS [Report Number]
	,Sum([Number of References]) As [Number of References]
	,'Total References Count' AS [Client Name] 
	,NULL AS AffiliateID
	,'' AS [Affiliate Name] 
	FROM #tmpCounts
	UNION ALL 
	SELECT [Report Number]
	,[Number of References]
	,[Client Name]
	,AffiliateID
	,[Affiliate Name]
	FROM #tmpCounts

END