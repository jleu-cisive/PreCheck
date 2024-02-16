  
-- ==============================================================================================================  
-- Author:  Suchitra Yellapantula  
-- Create date: 09/07/2016  
-- Description: Get the Client Verified Rate - Employment Verifications with Affiliate information Report Details  
-- Execution: EXEC [dbo].[GetEmploymentVerifiedRateWithAffiliate_ReportDetails]'02/01/2020','02/29/2020',4,0  
-- Modified BY radhika dereddy on 05/29/2019 in the where clause to filter by affiliate correctly.  
-- Moodifed By Amy Liu on 09/10/2020 for phase3 of project:IntranetModule: Status-SubStatus  
-- ==============================================================================================================  
CREATE PROCEDURE [dbo].[GetEmploymentVerifiedRateWithAffiliate_ReportDetails_test]  
 @Startdate date ,  
 @Enddate date,  
 --@AffiliateID int,  --code commented by Mainak for ticket id -55501
 @AffiliateIDs varchar(MAX) = '0',--code added by Mainak for ticket id -55501
 @Clno as smallint = 0  
AS  
BEGIN  
 SET NOCOUNT ON   
  
  --declare @Startdate date ='08/01/2020',  
  --  @Enddate date = '08/31/2020',  
  --  @AffiliateID int = 252 ,  
  --  @Clno as smallint = 0  

  --code added by Mainak for ticket id -55501 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
  --code added by Mainak for ticket id -55501 ends

  SELECT distinct  
   FORMAT(A.ApDate,'MM/dd/yyyy hh:mm tt') AS 'Report Date'  
   , A.APNO AS 'Report Number'  
   , R.Affiliate  
   , A.CLNO as 'Client Number'  
   , C.Name AS 'Client Name'  
   , CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS NULL THEN 'N/A' END AS [IsOneHR]  
   , A.[ApStatus] as 'Report Status' -- Modified by Humera for Request ID:28506 on 1/15/2018, Adding 2 columns  
   , CASE WHEN CONVERT(varchar(10), isnull(A.[ReopenDate],''), 101) + right(convert(varchar(32),isnull(A.[ReopenDate],''),100),8) = '01/01/1900 12:00AM' THEN 'N/A'  
       ELSE FORMAT(A.[ReopenDate],'MM/dd/yyyy hh:mm tt')  
      END as 'Re-Open Date' -- Modified by Deepak for Request ID:54304 on 04/26/2019, date format  
   , A.[Last] AS 'Last Name'  
   , A.[First] AS 'First Name'   
      , E.Employer AS 'Employer Name'  
   , E.Position_V AS 'Position'  
   , S.[Description] AS 'Status'  
   , isnull(SSS.SectSubStatus,'') AS 'SubStatus'  
  FROM Appl A  
                INNER JOIN Empl E ON A.APNO = E.APNO  
       INNER JOIN Client C ON A.CLNO = C.CLNO  
       INNER JOIN refAffiliate R ON R.AffiliateID = C.AffiliateID  
       INNER JOIN SectStat S ON S.Code = E.SectStat  
       LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum  
       LEFT JOIN DBO.SectSubStatus SSS (NOLOCK) ON E.SectStat = SSS.SectStatusCode AND E.SectSubStatusID = SSS.SectSubStatusID  
  WHERE    
  A.OrigCompDate >= @StartDate    
  AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)  
  AND (E.IsOnReport = 1)  
  AND E.IsHidden = 0  
  --AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)  --code commented by Mainak for ticket id -55501
  AND (@AffiliateIDs IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Mainak for ticket id -55501
  AND (A.CLNO = @Clno or @Clno = 0)-- Modified by Humera for Request ID:28506 on 1/22/2018  
END  