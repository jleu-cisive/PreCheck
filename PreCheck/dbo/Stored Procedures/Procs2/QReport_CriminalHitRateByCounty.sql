-- Alter Procedure RetCivilForWks
-- =============================================
-- Date: July 2, 2001
-- Author: Pat Coffer
--
-- Selects data needed to produce a civil
-- worksheet for all counties.
-- =============================================
--ALTER PROCEDURE dbo.RetCivilForWks
--	@CNTY_NO int
--AS
--SET NOCOUNT ON

----Y.State is accessed by index number, not name, so....
----      if change the position of State, go change the code 
--SELECT C.CivilID, Y.A_County, Y.State, Y.Country,.Y.CNTY_NO,
--       A.Apno, A.[Last], A.[First], A.Middle, A.SSN, A.DOB,
--       A.Addr_Num, A.Addr_Dir, A.Addr_Street, A.Addr_StType,
--       A.Addr_Apt, A.City, A.State, A.Zip, 
--       A.Alias1_First,A.Alias1_Middle,A.Alias1_Last,A.Alias1_Generation,
--       A.Alias2_First,A.Alias2_Middle,A.Alias2_Last,A.Alias2_Generation,
--       A.Alias3_First,A.Alias3_Middle,A.Alias3_Last,A.Alias3_Generation,
--       A.Alias4_First,A.Alias4_Middle,A.Alias4_Last,A.Alias4_Generation,
--       A.Alias, A.Alias2,A.Alias3, A.Alias4,
--       Y.Civ_Source, Y.Civ_Phone, Y.Civ_Fax, Y.Civ_Addr,
--       Y.Civ_Comment
--FROM Civil C
--JOIN Appl A ON C.Apno = A.Apno
--JOIN dbo.TblCounties Y on C.CNTY_NO = Y.CNTY_NO
--WHERE (C.[Clear] IS NULL)
--  AND (C.CNTY_NO = @CNTY_NO)
--ORDER BY Y.Country,Y.State,Y.A_County
--GO

--IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
--GO
--SET ANSI_NULLS ON
--SET QUOTED_IDENTIFIER ON
--GO

--IF @@ERROR<>0 OR @@TRANCOUNT=0 BEGIN IF @@TRANCOUNT>0 ROLLBACK SET NOEXEC ON END
--GO
-- Alter Procedure QReport_CriminalHitRateByCounty
-- =============================================
-- Author:		Humera Ahmed
-- Create date: 05/15/2020
-- Description:	Replacing inline query with this stored procedure for Q-report Criminal HitRate by County
-- EXEC QReport_CriminalHitRateByCounty '01/01/2021','12/31/2021',''
-- Modified by  Sahithi : Added  Vendor Name Column 09/03  - HDT :77073 
---------------------------------------------------------------------
--Modified by - vairavan 
--Modified Date - 06/15/2022
--Description: Ticketno-33637, Pulling Data from QReport Criminal Hit Search By either County Name or vendorid
-- =============================================

--EXEC QReport_CriminalHitRateByCounty_fix '01/01/2020','12/31/2022',' ',715036,'V'  --Search by vendorid
--EXEC QReport_CriminalHitRateByCounty_fix '01/01/2020','12/31/2022',' ',' ','C'  --Search by county

CREATE PROCEDURE [dbo].[QReport_CriminalHitRateByCounty] 
	-- Add the parameters for the stored procedure here
    @StartDate datetime,
	@EndDate datetime,
	@County varchar(100),-- if value pass as 'C' then Specify County else automatically  consider as ' '
	--code added by vairavan for ticket no - 33637 starts 
	@vendorid  int,-- if value pass as 'V' then Specify vendorid else  automatically  consider as ' '
	@Is_Srchby_Country_vendorid Char(1) --'C','V'
	--code added by vairavan for ticket no - 33637 ends 
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--code added by vairavan for ticket no - 33637 starts 
	IF @Is_Srchby_Country_vendorid = 'C'
	BEGIN
	  select @vendorid =  ' '
	END

	IF @Is_Srchby_Country_vendorid = 'V'
	BEGIN
	  select @County = 'ALL'
	END
	--code added by vairavan for ticket no - 33637 ends 

	IF @Is_Srchby_Country_vendorid in('C','V')----code added by vairavan for ticket no - 33637 
	BEGIN
    -- Insert statements for procedure here
	Select county [County] , [VendorName],Sum(OrderedCount) OrderedCount, Sum(HitCount) HitCount, ((100 * Sum(HitCount))/Sum(OrderedCount)) 'HitRate %' , sum(ClearCount) ClearCount, ((100 * sum(ClearCount))/Sum(OrderedCount)) 'ClearRate %'
    From  (  
			select (case when cty.County = '' then A_County else cty.County end) County,IR.R_Name as VendorName , count(1) OrderedCount,0 HitCount, 0 ClearCount 
			from Appl A (nolock) 
			inner join crim c (nolock) on A.Apno =c.Apno  
			INNER JOIN Iris_Researcher_Charges IRC (NOLOCK) ON IRC.Researcher_id = C.vendorid AND IRC.cnty_no = C.CNTY_NO
            INNER JOIN Iris_Researchers IR (NOLOCK) ON IR.r_id = IRC.researcher_id
			                   
			inner join dbo.TblCounties  cty (nolock) on c.cnty_no = cty.cnty_no   
			where 
				c.IsHidden = 0
				And Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
				And  (Case When @County = 'All'  or @County = '' then @County else
				(case when cty.County = '' then A_County else cty.County end) end) like @County + '%'
				and  c.vendorid =(Case When CAST(@vendorid  AS VARCHAR(50))= '0'  then c.vendorid else @vendorid end)	--code added by vairavan for ticket no - 33637 
			group by (case when cty.County = '' then A_County else cty.County end) ,ir.R_Name 
	
			UNION ALL  
			SELECT (case when cty.County = '' then A_County else cty.County end) County,ir.R_Name as VendorName , 0 OrderedCount,count(1) HitCount, 0 ClearCount 
			from Appl A (nolock) 
			inner join crim c (nolock) on A.Apno =c.Apno 
		    INNER JOIN Iris_Researcher_Charges IRC (NOLOCK) ON IRC.Researcher_id = C.vendorid AND IRC.cnty_no = C.CNTY_NO
            INNER JOIN Iris_Researchers IR (NOLOCK) ON IR.r_id = IRC.researcher_id 
			inner join dbo.TblCounties  cty (nolock) on c.cnty_no = cty.cnty_no   
			where 
				Clear = 'F' 
				AND c.IsHidden = 0
				and Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
				And  (Case When @County = 'All' or @County = '' then @County else (case when cty.County = '' then A_County else cty.County end) end) like @County + '%'
				and  c.vendorid =(Case When CAST(@vendorid  AS VARCHAR(50))= '0'  then c.vendorid else @vendorid end)	--code added by vairavan for ticket no - 33637 
			group by (case when cty.County = '' then A_County else cty.County end) ,IR.R_Name 

			UNION ALL  
			SELECT (case when cty.County = '' then A_County else cty.County end) County, IR.R_Name as VendorName , 0 OrderedCount,0 HitCount, count(1) ClearCount 
			from Appl A (nolock)
			 inner join crim c (nolock) on A.Apno =c.Apno 
	         INNER JOIN Iris_Researcher_Charges IRC (NOLOCK) ON IRC.Researcher_id = C.vendorid AND IRC.cnty_no = C.CNTY_NO
             INNER JOIN Iris_Researchers IR (NOLOCK) ON IR.r_id = IRC.researcher_id          
			 inner join dbo.TblCounties  cty (nolock) on c.cnty_no = cty.cnty_no   
			where 
				Clear = 'T' 
				AND c.IsHidden = 0
				and Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
				And  (Case When @County = 'All' or @County = '' then @County else (case when cty.County = '' then A_County else cty.County end) end) like @County + '%'  
				and  c.vendorid =(Case When CAST(@vendorid  AS VARCHAR(50))= '0'  then c.vendorid else @vendorid end)	--code added by vairavan for ticket no - 33637 
			group by (case when cty.County = '' then A_County else cty.County end)  ,IR.R_Name
	) Query  
	group by county,VendorName
	order by County,VendorName

	END
END
