-- =============================================
-- Author:		Humera Ahmed
-- Create date: 12/08/2020
-- Description:	Q-report that will show the items returned to the SJV module. It comes back to us as the following web status:  re-investigation needed, follow up, needs release, T&T, Employcheck, Overseas
-- added affilateID for ticket -34250

-- EXEC QReport_SJVModuleReturns '12/07/2020','12/07/2020'
-- =============================================
create PROCEDURE [dbo].[zz_bkup_QReport_SJVModuleReturns_10192022] 
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
  SELECT   
  w.description [Web Status]   
  ,count(cl.HEVNMgmtChangeLogID) [Number of Returns]   
 FROM changelog cl  
 INNER JOIN empl e ON cl.ID = e.EmplID  
 INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
 INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
 INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	  
 WHERE   
 cl.TableName ='Empl.web_status'   
 AND cl.NewValue = 54    
 AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate  
 AND cl.UserID = 'SJV'   AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate)
 GROUP BY w.description  

 
 UNION ALL  
  
 SELECT   
  w.description [Web Status]   
  ,count(cl.HEVNMgmtChangeLogID) [Number of Returns]   
 FROM changelog cl  
 INNER JOIN empl e ON cl.ID = e.EmplID  
 INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
  INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
 INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	  
 WHERE   
 cl.TableName ='Empl.web_status'   
 AND cl.NewValue = 74    
 AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate  
 AND cl.UserID = 'SJV'  AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate)
 GROUP BY w.description  
  
 UNION ALL   
  
 SELECT   
  w.description [Web Status]   
  ,count(cl.HEVNMgmtChangeLogID) [Number of Returns]   
 FROM changelog cl  
 INNER JOIN empl e ON cl.ID = e.EmplID  
 INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
 INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
 INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	  
 WHERE   
 cl.TableName ='Empl.web_status'   
 AND cl.NewValue = 5    
 AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate  
 AND cl.UserID = 'SJV'  AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate)
 GROUP BY w.description  
  
 UNION ALL   
  
 SELECT   
  w.description [Web Status]   
  ,count(cl.HEVNMgmtChangeLogID) [Number of Returns]   
 FROM changelog cl  
 INNER JOIN empl e ON cl.ID = e.EmplID  
 INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
  INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
 INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	  
 WHERE   
 cl.TableName ='Empl.web_status'   
 AND cl.NewValue = 87    
 AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate  
 AND cl.UserID = 'SJV' AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate) 
 GROUP BY w.description  
  
 UNION ALL   
  
 SELECT   
  w.description [Web Status]   
  ,count(cl.HEVNMgmtChangeLogID) [Number of Returns]   
 FROM changelog cl  
 INNER JOIN empl e ON cl.ID = e.EmplID  
 INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
  INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
 INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	  
 WHERE   
 cl.TableName ='Empl.web_status'   
 AND cl.NewValue = 78    
 AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate  
 AND cl.UserID = 'SJV'  AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate)
 GROUP BY w.description  
  
 UNION ALL   
  
 SELECT   
  w.description [Web Status]   
  ,count(cl.HEVNMgmtChangeLogID) [Number of Returns]   
 FROM changelog cl  
 INNER JOIN empl e ON cl.ID = e.EmplID  
 INNER JOIN dbo.Websectstat w ON cl.NewValue = w.code  
  INNER JOIN  PreCheck.dbo.Appl AS A(NOLOCK)  on a.APNO=e.Apno
 INNER JOIN PreCheck.dbo.Client AS c(NOLOCK) ON a.CLNO = c.CLNO	  
 WHERE   
 cl.TableName ='Empl.web_status'   
 AND cl.NewValue = 57    
 AND cast(cl.ChangeDate AS date) >= @StartDate AND cast(cl.ChangeDate AS date) <= @EndDate  
 AND cl.UserID = 'SJV'  AND c.AffiliateId = IIF(@Affiliate=0, c.AffiliateId, @Affiliate)
 GROUP BY w.description  

END
