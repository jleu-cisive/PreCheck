-- ==============================================================================================================  
-- Author:           Suchitra Yellapantula  
-- Create date: 09/07/2016  
-- Description:      Get the Client Verified Rate - Education Verifications with Affiliate information Report Details  
-- Exec [dbo].[GetEducationVerifiedRateWithAffiliate_ReportDetails] '01/01/2020', '01/31/2020', '0', 3115  
-- Exec [dbo].[GetEducationVerifiedRateWithAffiliate_ReportDetails] '05/01/2019', '05/20/2019', 'AdventHealth', 0  
-- Modified by Prasanna on 04/26/2019 for HDT#51303(Change date format)  
-- Modified by Humera Ahmed on 03/06/2020 for HDT#67981(Modify Existing Q-Report Logic/Education)  
-- Modified by Humera Ahmed on 10/09/2020 for HDT#79552 Add SubStatus Column: Client Verified Rate - Education Verifications with Affiliate - Report Details  
-- Modified By Mainak Bhadra for Ticket No.55501,modifiing Old parameter @Affiliate int to Varchar(max) for using multiple Affiliate IDs separated with : 
-- ==============================================================================================================  
CREATE PROCEDURE [dbo].[GetEducationVerifiedRateWithAffiliate_ReportDetails]  
       -- Add the parameters for the stored procedure here  
@Startdate date ,  
@Enddate date,  
--@Affiliate int, --code commented by Mainak for ticket id -55501
@Affiliate varchar(MAX) = '0',--code added by Mainak for ticket id -55501
@Clno as smallint = 0 -- Modified by Humera for Request ID:28506 on 1/18/2018  
AS  
BEGIN  
       -- SET NOCOUNT ON added to prevent extra result sets from  
       -- interfering with SELECT statements.  

	  --code added by Mainak for ticket id -55501 starts
	IF @Affiliate = '0' 
	BEGIN  
		SET @Affiliate = NULL  
	END
	--code added by Mainak for ticket id -55501 ends
  
       SELECT distinct  
              FORMAT(A.ApDate,'MM/dd/yyyy hh:mm tt') AS 'Report Date'  
              , A.APNO AS 'Report Number'  
              , R.Affiliate  
              , A.CLNO as 'Client Number'  
              , C.Name AS 'Client Name'  
              , CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS NULL THEN 'N/A' END AS [IsOneHR]  
                     -- Modified by Humera for Request ID:28506 on 1/15/2018, Adding 2 new columns  
                     -- case when A.[ApStatus] = 'F' then 'F - Final/Closed'   
                           --when A.[ApStatus] = 'P' then 'P - Pending/InProgress'  
                     -- end as 'Report Status',   
              , A.[ApStatus] as 'Report Status'   
                     --ISNULL(CONVERT(varchar(50),  A.[ReopenDate] ,120),'N/A') as 'Re-Open Date',  
              , ISNULL(FORMAT(A.[ReopenDate],'MM/dd/yyyy hh:mm tt'),'N/A') as 'Re-Open Date'  
              , A.[Last] AS 'Last Name'  
              , A.[First] AS 'First Name'   
              , E.School AS 'Educational Institution Name'  
              , E.Degree_V AS 'Degree'  
              , S.[Description] AS 'Status'  
              , isnull(sss.SectSubStatus, '') as [SubStatus]  
       FROM Appl A(NOLOCK)  
              INNER JOIN Educat E(NOLOCK) ON A.APNO = E.APNO  
              INNER JOIN Client C(NOLOCK) ON A.CLNO = C.CLNO  
              INNER JOIN refAffiliate R(NOLOCK) ON R.AffiliateID = C.AffiliateID  
              INNER JOIN SectStat S ON S.Code = E.SectStat  
              LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum  
              Left join dbo.SectSubStatus sss (nolock) on e.SectStat = sss.SectStatusCode and e.SectSubStatusID = sss.SectSubStatusID  
       WHERE    
              A.OrigCompDate >= @StartDate    
              AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)  
              AND (E.IsOnReport = 1)  
              AND E.IsHidden = 0  
              --AND C.AffiliateID = IIF(@Affiliate=0,C.AffiliateID,@Affiliate)  --code commented by Mainak for ticket id -55501 
			  AND (@Affiliate IS NULL OR C.AffiliateID IN (SELECT value FROM fn_Split(@Affiliate,':')))--code added by Mainak for ticket id -55501
              AND (A.CLNO = @Clno or @Clno = 0)-- Modified by Humera for Request ID:28506 on 1/18/2018  
         
END  