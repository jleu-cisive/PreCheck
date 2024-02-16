-- Alter Procedure Total_Number_Of_Criminal_Searches_ByCounty_ByState
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 03/07/2017
-- Description: Currently this report only pulls results if we actually performed criminal searches in the state listed during the designated timeframe.  
-- We will need this report to include all counties even if the Count=0. 
-- We are tracking the volume of searches by month and some counties are left off the list in some months and are on the list in others based on volume. 

-- Modified By Radhika Dereddy on 04/04/2018
-- Requester - Misty Smallwood 
--Add a column named DeliveryMethod = The delivery method should be pulled from Intranet/Iris within the Researcher listing for that particular search. 
--If you need to reference to another Qreport that currently pulls the deliverymethod from iris, you can use the Crim Pending Counts Status/Delivery - the 8th column is deliverymethod)
--Add a column named Vendor = The vendor information should be pulled from the same location within Iris for the deliverymothod, 
--just a different field named Vendor. This is highlighted in the 2nd screen shot at top of the page.
-- =============================================

--[Total_Number_Of_Criminal_Searches_ByCounty_ByState] '02/01/2018','02/20/2018','CO','usa', 0 
--[Total_Number_Of_Criminal_Searches_ByCounty_ByState] '02/01/2018','02/28/2018','TX','usa', 1


CREATE PROCEDURE [dbo].[Total_Number_Of_Criminal_Searches_ByCounty_ByState]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@State varchar(2),
	@Country varchar(50),
	@ByClient Bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

Create Table #temp1
(
 Apno int,
 TotalCount int,
 County varchar(40),
 State varchar(25),
 Country varchar(25),
 DeliveryMethod varchar(50),
 Vendor varchar(50)

)

	INSERT INTO #temp1 (Apno, TotalCount, County, State, Country, DeliveryMethod, Vendor)
	SELECT c.Apno, count(*) as count, cc.a_county, cc.state, cc.country,  c.DeliveryMethod, ir.R_Name
	FROM crim c WITH (NOLOCK) 
	INNER JOIN dbo.TblCounties cc  WITH (NOLOCK) ON c.cnty_no = cc.cnty_no 
	INNER JOIN Iris_Researchers ir WITH (NOLOCK) on c.vendorid = ir.R_id
	WHERE crimenteredtime >= @StartDate 
	AND crimenteredtime < @EndDate
	AND isnull(cc.state,'') like ('%' + @State + '%' )
	AND isnull(cc.country,'') like ('%' + @Country + '%' )
	GROUP BY c.apno, cc.a_county,cc.state,cc.country,  c.DeliveryMethod, ir.R_Name

Create Table #temp3
(
 Apno int,
 TotalCount int,
 County varchar(40),
 State varchar(25),
 Country varchar(25),
 DeliveryMethod varchar(50),
 Vendor varchar(50)

)
	INSERT INTO #TEMP3 (APNO, TOTALCOUNT, COUNTY, STATE, COUNTRY, DeliveryMethod, Vendor)
	SELECT 0 AS APNO, 0 AS TOTALCOUNT, A_COUNTY, STATE, COUNTRY, c.DeliveryMethod, ir.R_Name 
	FROM dbo.TblCounties cc
	INNER JOIN Crim c  WITH (NOLOCK)  ON cc.cnty_no = c.cnty_no  
	INNER JOIN Iris_Researchers ir WITH (NOLOCK) on c.vendorid = ir.R_id
	WHERE (STATE LIKE ('%' + @STATE + '%' )
	AND COUNTRY  LIKE ('%' + @COUNTRY + '%' ))
	AND A_COUNTY NOT IN (SELECT DISTINCT COUNTY FROM #TEMP1) 
	

	--Select distinct County from #temp1

Create Table #temp2
(
 Apno int,
 TotalCount int,
 CLNO int,
 ClientName varchar(100),
 County varchar(40),
 State varchar(25),
 Country varchar(25),
 DeliveryMethod varchar(50),
 Vendor varchar(50)

)
	INSERT INTO #temp2 (Apno, TotalCount, CLNO, CLientName, County, State, Country, DeliveryMethod, Vendor)
	SELECT c.apno, count(*) as count, A.CLNO, CL.Name, cc.a_county, cc.state, cc.country,  c.DeliveryMethod, ir.R_Name 
	FROM crim c WITH (NOLOCK) 
	INNER JOIN dbo.TblCounties cc  WITH (NOLOCK)  ON c.cnty_no = cc.cnty_no  
	INNER JOIN Appl A WITH (NOLOCK) ON c.Apno = A.Apno 
	INNER JOIN Client CL WITH (NOLOCK) ON A.CLNO = CL.CLNO  
	INNER JOIN Iris_Researchers ir WITH (NOLOCK) on c.vendorid = ir.R_id
	WHERE crimenteredtime >= @StartDate 
	AND crimenteredtime < @EndDate
	AND isnull(cc.state,'') like ('%' + @State + '%' )
	AND isnull(cc.country,'') like ('%' + @Country + '%' )
	GROUP BY c.apno, A.CLNO,CL.Name,cc.a_county,cc.state,cc.country, c.DeliveryMethod, ir.R_Name 
	ORDER BY A.CLNO


Create Table #temp4
(
 Apno int,
 TotalCount int,
 CLNO int,
 ClientName varchar(100),
 County varchar(40),
 State varchar(25),
 Country varchar(25),
 DeliveryMethod varchar(50),
 Vendor varchar(50)

)

INSERT INTO #temp4 (Apno, TotalCount, CLNO, CLientName, County, State, Country, DeliveryMethod, Vendor)
SELECT 0 AS APNO, 0 AS TOTALCOUNT, '' as CLNO, '' as ClientName, A_COUNTY, STATE, COUNTRY,  c.DeliveryMethod, ir.R_Name 
FROM dbo.TblCounties cc
INNER JOIN Crim c  WITH (NOLOCK)  ON cc.cnty_no = c.cnty_no  
INNER JOIN Iris_Researchers ir WITH (NOLOCK) on c.vendorid = ir.R_id
WHERE (STATE LIKE ('%' + @STATE + '%' )
AND COUNTRY  LIKE ('%' + @COUNTRY + '%' ))
AND A_COUNTY NOT IN (SELECT DISTINCT COUNTY FROM #TEMP2) 



IF @ByClient = 0 
	
	SELECT Count(distinct Apno) as Count, County, State, Country, DeliveryMethod, Vendor FROM #temp1
	GROUP BY County, State, Country,DeliveryMethod, Vendor

	UNION ALL

	SELECT APNO, County, State, Country, DeliveryMethod, Vendor FROM #temp3
	GROUP BY APNO, County, State, Country, DeliveryMethod, Vendor
		
ELSE

	SELECT Count( Apno) as Count, CLNO, ClientName, County, State, Country, DeliveryMethod, Vendor FROM #temp2
	Group BY CLNO, ClientName, County, State, Country, DeliveryMethod, Vendor
	

	UNION ALL

	SELECT APNO, CLNO, ClientName, County, State, Country, DeliveryMethod, Vendor FROM #temp4
	Group BY APNO, CLNO, ClientName, County, State, Country, DeliveryMethod, Vendor

	

END

DROP TABLE #temp1
DROP TABLE #temp2
