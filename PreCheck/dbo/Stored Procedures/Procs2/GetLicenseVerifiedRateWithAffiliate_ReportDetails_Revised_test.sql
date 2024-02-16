-- =============================================      
-- Author:  Humera Ahmed       
-- Create date: 3/2/2020      
-- Description: Get the Client Verified Rate - License Verifications with Affiliate information Report Details      
-- Execution: GetLicenseVerifiedRateWithAffiliate_ReportDetails_Revised '05/01/2019','05/20/2019',0,0,''     
-- Modified by Prasanna on 10/12/2020 for HDT#79550 Add SubStatus Column: Client Verified Rate - License with affiliate - Reports Revised  
-- =============================================         
CREATE PROCEDURE [dbo].[GetLicenseVerifiedRateWithAffiliate_ReportDetails_Revised_test]       
 -- Add the parameters for the stored procedure here      
   @Startdate date,     
   @Enddate date,   
   --@AffiliateId int = 0, --code commented by Mainak for ticket id -55501
   @AffiliateIDs varchar(MAX) = '0',--code added by Mainak for ticket id -55501 
   @Clno as smallint = 0,      
   @LicenseState as varchar(8) =''      
AS      
BEGIN      
 -- SET NOCOUNT ON added to prevent extra result sets from      
 -- interfering with SELECT statements.      
 SET NOCOUNT ON;      

   --code added by Mainak for ticket id -55501 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by Mainak for ticket id -55501 ends
      
    -- Insert statements for procedure here      
 SELECT distinct   
  FORMAT(a.Apdate,'MM/dd/yyyy hh:mm tt') as 'Report Date'   
  , A.APNO AS 'Report Number'  
  , R.Affiliate  
  , A.CLNO as 'Client Number'  
  , C.Name AS 'Client Name'  
  , CASE WHEN F.IsOneHR = 1 THEN 'True' WHEN F.IsOneHR = 0 THEN 'False' WHEN F.IsOneHR IS NULL THEN 'N/A' END AS [IsOneHR]  
  , A.[ApStatus] as 'Report Status'       
  , ISNULL(FORMAT(a.ReOpenDate,'MM/dd/yyyy hh:mm tt'),'N/A') as 'Re-Open Date'  
  , A.[Last] AS 'Last Name'  
  , A.[First] AS 'First Name'      
  , P.Lic_Type_V AS 'License Type'  
  , P.State_V AS 'License State'  
  , P.Lic_No_V as [License Number]  
  , S.[Description] AS 'Status'  
  , isnull(sss.SectSubStatus, '') as [SubStatus]  
  FROM Appl A      
       INNER JOIN ProfLic P ON A.APNO = P.Apno       
       INNER JOIN Client C ON A.CLNO = C.CLNO      
       INNER JOIN refAffiliate R ON R.AffiliateID = C.AffiliateID      
       INNER JOIN SectStat S ON S.Code = P.SectStat     
    LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum   
    LEFT JOIN dbo.SectSubStatus sss (nolock) on [P].SectStat = sss.SectStatusCode and [P].SectSubStatusID = sss.SectSubStatusID  
  WHERE     
   A.OrigCompDate >= @StartDate    
   AND A.OrigCompDate < DATEADD(DAY, 1, @EndDate)    
   AND (P.IsOnReport = 1)      
   AND P.IsHidden = 0      
   --AND C.AffiliateId  = IIF(@AffiliateId=0, R.AffiliateId, @AffiliateId)  --code commented by Mainak for ticket id -55501 
   AND (@AffiliateIDs IS NULL OR C.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Mainak for ticket id -55501  
   AND c.CLNO = IIF(@CLNO=0, c.CLNO, @CLNO)     
   AND (P.State_V = @LicenseState OR @LicenseState ='')      
      
END 