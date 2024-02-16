-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 01/06/2017
-- Description:	<Description,,>
-- EXEC MVR_Records_BY_Date_State '01/09/2017', '01/10/2017' 
-- =============================================
CREATE PROCEDURE [dbo].[MVR_Records_BY_Date_State]
	-- Add the parameters for the stored procedure here
	 @StartDate datetime,
	 @EndDate datetime

	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  select a.apno,a.clno, r.Affiliate, d.ordered, a.dl_state, a.dl_number,  rc.ClientType, rb.BillingCycle
  from dl d with (nolock) 
  inner join appl a with (nolock) on d.apno = a.apno        
  inner join client c  (nolock) on a.clno = c.clno     
  inner join refClientType rc on rc.ClientTypeID = c.ClientTypeID    
  left join refaffiliate r  (nolock) on c.affiliateid = r.AffiliateID
  inner join refBillingCycle rb on rb.BillingCycleId = c.BillingCycleID  
  where (CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, d.DateOrdered))) >= @StartDate AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, d.DateOrdered))) < = @EndDate)
 -- and a.dl_state like '%' + @State + '%'  and a.clno like '%' + @CLNO + '%'


  
  
END
