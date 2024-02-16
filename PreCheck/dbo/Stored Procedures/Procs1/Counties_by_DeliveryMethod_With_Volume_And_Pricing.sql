
/* Created by Doug on 07/09/2021 for Vendor Assignment */ 
--[dbo].[Counties_by_DeliveryMethod_With_Volume_And_Pricing] '01/01/2021','07/09/2021','Web service'
CREATE PROCEDURE [dbo].[Counties_by_DeliveryMethod_With_Volume_And_Pricing]  
 -- Add the parameters for the stored procedure here  
 --DECLARE  
 @StartDate Date,  
 @EndDate Date,  
 @DeliveryMethod Varchar(100)
 AS
 BEGIN

drop table if exists #tmpAll
  
  SELECT DISTINCT cnty.A_County AS County, cnty.[State], r.R_Delivery AS DeliveryMethod,R_Name as VendorName, COUNT(c.CrimID) AS Volume,R_id as VendorId
      into #tmpAll
   from Crim c(nolock)   
   inner join dbo.TblCounties cnty(NOLOCK) on c.CNTY_NO = cnty.CNTY_NO  
   INNER JOIN dbo.Iris_Researchers AS r(NOLOCK) ON C.vendorid = R.R_id  
   WHERE c.IsHidden = 0  
     AND CAST(c.Crimenteredtime as Date) BETWEEN @StartDate AND DATEADD(d,1,@EndDate)  
  AND r.R_Delivery LIKE '%' + @DeliveryMethod + '%'  
   GROUP BY cnty.A_County,cnty.[State],r.R_Delivery,R_Name,R_id
   ORDER BY cnty.A_County 

   --select * from #tmpAll

   select distinct t.*,ic.Researcher_combo,ic.Researcher_other, ic.Researcher_CourtFees, ic.Researcher_aliases_count,ic.Researcher_Default,ic.CNTY_NO
   from #tmpAll t inner join iris_researcher_charges ic WITH (NOLOCK) ON t.VendorId =  ic.researcher_id  and T.County = IC.Researcher_county and T.State = ic.Researcher_state
  -- WHERE ic.CNTY_NO is not null
  END