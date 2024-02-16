-- =======================================================================  
-- Author: Radhika Dereddy  
-- Create date: 07/27/2021  
-- Description: Creating a Stored procedure from Inline query  
-- for County Criminal Searches by Ordered Date  
-- EXEC [QReport_CountyCriminalSearchesByOrderedDate] '01/01/2022','01/31/2022',0  
-- Modified by: Prasanna on 02/10/2022 for HDT#18138:add another column for Vendor entered date  
-- ========================================================================  
CREATE PROCEDURE [dbo].[QReport_CountyCriminalSearchesByVendorEnteredDate_test]   
 -- Add the parameters for the stored procedure here  
@StartDate datetime,  
@EndDate datetime,  
@CNTY_NO int,
@VendorIDs varchar(max)='0'  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  

 
    DROP TABLE if exists #TmpVendor  

	select R_id,R_Name into #TmpVendor from Iris_Researchers where 1=2
 
  if  @VendorIDs='0'
 begin 
	insert into #TmpVendor
	select R_id,R_Name  from Iris_Researchers
 end
 else 
 begin
	insert into #TmpVendor
	select R_id,R_Name from Iris_Researchers where R_id in (select value from fn_split(@VendorIDs,':')) 
 end 
  
  
  select * from 
  (

  SELECT cr.crimid, a.apno, cr.county, cr.clear,cr.ordered,rf.Affiliate, r.R_Name AS VendorName,  
  case when cr.deliverymethod <> 'web service' then max(cv.EnteredDate)  
 else   
   case when  max(i.updated_on) is null then max(cr.Crimenteredtime)  
   else DATEADD(hh, -7,  max(i.updated_on) ) -- utc time conversion to cst  
   end  
 end as [Vendor entered date]  
  FROM dbo.Crim Cr WITH(NOLOCK)  
  INNER JOIN dbo.APPL A WITH(NOLOCK) ON Cr.APNO = A.APNO  
  INNER JOIN dbo.Client c WITH(NOLOCK) ON A.CLNO = C.CLNO  
  INNER JOIN dbo.refAffiliate rf WITH(NOLOCK) ON C.AffiliateID = rf.AffiliateID  
  INNER JOIN dbo.Counties cc WITH(NOLOCK) ON cr.CNTY_NO = cc.CNTY_NO  
  INNER JOIN #TmpVendor r WITH(NOLOCK) ON cr.vendorid = r.R_id  
  left outer join iris_ws_screening i WITH(NOLOCK)  on cr.CrimID = i.crim_id  
  left outer join CriminalVendor_Log cv WITH(NOLOCK) on cr.apno = cv.apno and cr.cnty_no = cv.CNTY_NO     
  where Cr.CNTY_NO = IIF(@CNTY_NO=0,Cr.CNTY_NO,@CNTY_NO)  
  AND cr.ordered is not null    
  AND 
	(
		(TRY_CONVERT( datetime, cv.EnteredDate, 101) >= @StartDate AND TRY_CONVERT(datetime, cv.EnteredDate, 101) <= @EndDate ) or 
		(TRY_CONVERT( datetime, cr.Crimenteredtime, 101) >= @StartDate AND TRY_CONVERT(datetime, cr.Crimenteredtime, 101) <= @EndDate ) or 
		(TRY_CONVERT( datetime, i.updated_on, 101) >= @StartDate AND TRY_CONVERT(datetime, i.updated_on, 101) <= @EndDate ) 
	)

  group by cr.crimid, a.apno, cr.county, cr.clear,cr.ordered,rf.Affiliate, r.R_Name, cr.CNTY_NO, cr.deliverymethod    
  ) x
  where x.[Vendor entered date] is not null
  AND (TRY_CONVERT( datetime, x.[Vendor entered date], 101) >= @StartDate AND TRY_CONVERT(datetime, x.[Vendor entered date], 101) <= @EndDate ) 
    
    
  END  