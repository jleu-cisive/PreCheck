 
 -- =============================================  
-- Modified By: DEEPAK VODETHELA   
-- Create date: 07/07/2017  
-- Description: To capture all the Web Status Updates for Education  
-- Execution:  EXEC dbo.WebStatus_Update_Tracking_Report_Education '07/07/2018','07/07/2018'  
-- modified by : Tanay Dubey on 08/16/2022
-- description : added Ed.InvestigatorAssigneddate on line 21
-- =============================================  
CREATE PROCEDURE [dbo].[WebStatus_Update_Tracking_Report_Education]  
 -- Add the parameters for the stored procedure here  
    @StartDate date,   
    @EndDate date  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 SELECT   a.Apno as ReportNumber,Ed.SectStat,  
   dbo.elapsedbusinessdays_2(a.ApDate, getDate() +1) as BusinessDays,  
   a.ApDate as ReportCreatedDate, Ed.Investigator,Ed.InvestigatorAssigneddate,  
   Ed.School as SchoolName, C.Name as CLientName, rtrim(ltrim(Ws.Description)) as WebStatus,  
   Ed.Web_Updated, MainDB.dbo.fnGetTimeZone(Ed.[ZipCode], Ed.[City], Ed.[State]) [TimeZone],  
   RA.Affiliate,a.UserID CAM,Parent =CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name  
 FROM Educat AS Ed WITH(NOLOCK)  
 INNER JOIN Appl AS a WITH(NOLOCK) on a.Apno = Ed.Apno  
 INNER JOIN CLient AS C WITH(NOLOCK) on a.CLNO = C.CLNO  
 INNER JOIN WebSectStat AS Ws WITH(NOLOCK) on Ws.code = Ed.web_status  
 INNER JOIN refAffiliate AS ra WITH (NOLOCK) ON ra.AffiliateID = c.AffiliateID  
 LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO  
 WHERE Ed.IsOnReport = 1   
  AND Ed.SectStat = '9'   
     AND (CAST(a.[ApDate] AS DATE) BETWEEN @StartDate AND DATEADD(d,1,@EndDate))  
  
END