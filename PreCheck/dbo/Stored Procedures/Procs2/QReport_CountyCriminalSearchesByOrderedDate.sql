-- =======================================================================  
-- Author: Radhika Dereddy  
-- Create date: 07/27/2021  
-- Description: Creating a Stored procedure from Inline query  
-- for County Criminal Searches by Ordered Date  
-- EXEC [QReport_CountyCriminalSearchesByOrderedDate] '01/01/2022','01/31/2022',0  
-- Modified by: Prasanna on 02/10/2022 for HDT#18138:add another column for Vendor entered date  
----------------------------------------------------------------------------
--Modified by: YSharma on 05/03/2023 for HDT #92950 : added two new column i.e. CLNO,ClientName
-- ========================================================================  
CREATE PROCEDURE [dbo].[QReport_CountyCriminalSearchesByOrderedDate]   
 -- Add the parameters for the stored procedure here  
@StartDate datetime,  
@EndDate datetime,  
@CNTY_NO int  
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 
 SELECT C.CLNO,C.Name AS ClientName,cr.crimid, a.apno, cr.county, cr.clear,cr.ordered,rf.Affiliate, r.R_Name AS VendorName,  
  case when cr.deliverymethod <> 'web service' then max(cv.EnteredDate)  
 else   
   case when  max(i.updated_on) is null then max(cr.Crimenteredtime)  
   else DATEADD(hh, -7,  max(i.updated_on) ) -- utc time conversion to cst  
   end  
 end as [Vendor entered]  
  FROM dbo.Crim Cr WITH(NOLOCK)  
  INNER JOIN dbo.APPL A WITH(NOLOCK) ON Cr.APNO = A.APNO  
  INNER JOIN dbo.Client c WITH(NOLOCK) ON A.CLNO = C.CLNO  
  INNER JOIN dbo.refAffiliate rf WITH(NOLOCK) ON C.AffiliateID = rf.AffiliateID  
  INNER JOIN dbo.Counties cc WITH(NOLOCK) ON cr.CNTY_NO = cc.CNTY_NO  
  INNER JOIN Iris_Researchers r WITH(NOLOCK) ON cr.vendorid = r.R_id  
  left outer join iris_ws_screening i WITH(NOLOCK)  on cr.CrimID = i.crim_id  
  left outer join CriminalVendor_Log cv WITH(NOLOCK) on cr.apno = cv.apno and cr.cnty_no = cv.CNTY_NO     
  where 
   Cr.CNTY_NO = IIF(@CNTY_NO=0,Cr.CNTY_NO,@CNTY_NO)  
  AND cr.ordered is not null    
  AND (TRY_CONVERT( datetime, cr.ordered, 101) >= @StartDate AND TRY_CONVERT(datetime, cr.ordered, 101) <= @EndDate ) 
  group by C.CLNO,C.Name,cr.crimid, a.apno, cr.county, cr.clear,cr.ordered,rf.Affiliate, r.R_Name, cr.CNTY_NO, cr.deliverymethod



  END