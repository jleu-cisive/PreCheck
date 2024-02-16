
-- ============================================================
-- Created By: Tanay Dubey   
-- Create date: 08/15/2022 
-- Description: Closed Reports with Unverified/See Attached and webstatus in follow-up date given  
-- Execution:  EXEC dbo.WebStatus_ClosedReports_FollowUpDateGiven_Employment
  
 --EXEC dbo.WebStatus_ClosedReports_FollowUpDateGiven_Employment 
 -- ===============================================================

CREATE PROCEDURE [dbo].[WebStatus_ClosedReports_FollowUpDateGiven_Employment]  
 -- Add the parameters for the stored procedure here  
    @StartDate date,   
    @EndDate date  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 --declare     @StartDate date='07/01/2022',   
 --   @EndDate date = '08/05/2022'  
  
 SELECT  a.Apno as ReportNumber,Ep.SectStat, isnull(sss.SectSubStatus,'') SectSubStatus,  
   dbo.elapsedbusinessdays_2(a.ApDate, getDate() +1) as BusinessDays,  
   a.ApDate as ReportCreatedDate, AF.FollowupOn As FollowupDate,Ep.Investigator,   
   Ep.Employer as Employer, C.Name as CLientName, rtrim(ltrim(Ws.Description)) as WebStatus,  
   Ep.Web_Updated, MainDB.dbo.fnGetTimeZone(Ep.[ZipCode], Ep.[City], Ep.[State]) [TimeZone],  
   RA.Affiliate,a.UserID CAM,Parent =CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name  
 FROM Empl AS Ep WITH(NOLOCK)  
 INNER JOIN Appl AS a WITH(NOLOCK) on a.Apno = Ep.Apno  
 INNER JOIN CLient AS C WITH(NOLOCK) on a.CLNO = C.CLNO  
 INNER JOIN WebSectStat AS Ws WITH(NOLOCK) on Ws.code = Ep.web_status  
 INNER JOIN refAffiliate AS ra WITH (NOLOCK) ON ra.AffiliateID = c.AffiliateID  
 Left JOIN FollowUp AS F WITH(NOLOCK) on a.Apno = F.Apno  
 LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO  
 left join dbo.SectSubStatus sss with(nolock) on Ep.SectStat = sss.SectStatusCode and Ep.SectSubStatusID = sss.SectSubStatusID  
 Left Join ApplSections_Followup AS AF with(Nolock) On  AF.Apno = Ep.Apno  And (Af.CompletedBy is null And AF.CompletedOn is null)    
 WHERE Ep.IsOnReport = 1   
  AND Ep.SectStat in ('6','U') AND Ws.code = 63  
     AND (CAST(a.[ApDate] AS DATE) BETWEEN @StartDate AND @EndDate)  
  
END  