
-- =============================================  
-- Author:  Radhika Dereddy  
-- Create date: 11/05/2021  
-- Description: Identify Missing DS Monitoring Case Tickets  
--exec precheck..[IdentifyMissingDSMonitoringCaseTickets] '09/19/2022','10/02/2022'
-- =============================================  
CREATE PROCEDURE [dbo].[IdentifyMissingDSMonitoringCaseTickets]   
@StartDate datetime,  
@EndDate datetime  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
--SET @StartDate = DATEADD(Day, -1, DATEDIFF(Day, 0, GetDate()))  
--SET @EndDate =  CAST(CONVERT(char(8), @StartDate, 112) + ' 23:59:59.99' AS DATETIME)   
  
      
SELECT  rd.Firstname, rd.Lastname,ci.APNO  
FROM Precheck..OCHS_CandidateInfo ci(NOLOCK)  
INNER JOIN Precheck..OCHS_ResultDetails rd (NOLOCK) ON rd.OrderIDOrApno = cast(ci.OCHS_CandidateInfoID as varchar) AND rd.OrderStatus='Donor Email Sent'  
INNER JOIN [Enterprise].PreCheck.vwClient C WITH (NOLOCK)ON ci.CLNO = C.ClientId  
INNER JOIN Precheck..Appl A(NOLOCK) ON ci.APNO = a.APNO AND a.EnteredVia ='CIC'  
LEFT OUTER JOIN NotificationHub.dbo.schedulerlogitemsub s WITH(NOLOCK) ON s.notificationto like '%HCA%' and s.emailsubject like '%DS Monitoring%'  
   AND s.EmailSubject  like Concat('%', rd.Firstname ,'%') and s.EmailSubject  like Concat('%' , rd.LastName,'%')  
WHERE rd.OrderIDOrAPNO IS NOT NULL   
AND rd.LastUpdate between @StartDate and @EndDate  
AND (c.ClientId=ISNULL(7519,c.ClientId) OR c.ParentId=ISNULL(7519,c.ParentId))  
AND S.NotificationTo IS NULL  
AND ci.APNO IS NOT NULL and ci.APNO <> 0  
  
  
END  