-- =============================================
-- Author:		Humera Ahmed
-- Create date: 01/06/2020
-- Description:	Q-report that will show details of the items returned from SJV module. It comes back to us as the following web status:  re-investigation needed, follow up, needs release, T&T, Employcheck, Overseas
-- Vivek added affilate ID -34245

-- EXEC QReport_SJVModuleReturnsDetails '12/07/2020','12/07/2020',0
-- =============================================
  CREATE PROCEDURE [dbo].[QReport_SJVModuleReturnsDetails] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@Affiliate int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

       -- Insert statements for procedure here  
 
 -- 10/20/2022 - Pradip - replaced logic with new logic below
 /* 
 SELECT   
  w.description [Web Status]   
  --,count(cl.HEVNMgmtChangeLogID) [Number of Returns]   
  , e.Apno [Report #]  
  , e.Employer  
 FROM changelog cl  
 INNER JOIN empl e ON cl.ID = e.EmplID  
 INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
 INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
 INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	 
 WHERE   
 cl.TableName ='Empl.web_status'   
 AND cl.NewValue IN (54,74,5,87,78,57)   
 AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate  
 AND cl.UserID = 'SJV'  AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate)
 order by w.description  
 
 */


 
SELECT cl.* 
INTO #tempWebStatus  
FROM changelog cl  	  
WHERE  1 = 1 
AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate    
AND cl.TableName = 'Empl.web_status'
AND cl.NewValue IN ('54','74','5','87','78','57')    
AND cl.UserID = 'SJV'   


SELECT cl.* 
INTO #tempPending  
FROM changelog cl    
WHERE  cl.ChangeDate >= @StartDate  
AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate    
AND cl.TableName = 'Empl.SectStat' 
AND cl.NewValue = '9'
AND cl.UserID = 'SJV'



SELECT w.description [Web Status]   
	 , e.Apno [Report #]  
	 , e.Employer  
from #tempWebStatus cl
INNER JOIN #tempPending tp ON cl.ID = tp.ID AND cl.ChangeDate = tp.ChangeDate
INNER JOIN empl e ON cl.ID = e.EmplID  
INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	
INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
WHERE c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate)






END
