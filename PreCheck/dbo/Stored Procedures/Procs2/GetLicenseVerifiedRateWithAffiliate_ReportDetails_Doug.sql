-- =============================================    
-- Author:  Humera Ahmed     
-- Create date: 1/25/2018    
-- Description: Get the Client Verified Rate - License Verifications with Affiliate information Report Details    
-- Execution: GetLicenseVerifiedRateWithAffiliate_ReportDetails '05/01/2019','05/20/2019','AdventHealth',0,''      
-- =============================================   
-- =============================================    
-- Update:  Doug DeGenaro     
-- Update date:04/29/2019   
-- Description: Update the date fields to show MM/DD/YYYY HH:MM:SS AM/PM  
-- ============================================= 
-- =============================================    
-- Update:  Doug DeGenaro     
-- Update date:08/16/2019   
-- Description: Update the search filter to filter by AffiliateId and Add LicenseNumber after LicenseState
-- [dbo].[GetLicenseVerifiedRateWithAffiliate_ReportDetails_Doug] '05/01/2019','05/20/2019',0   
-- =============================================       
CREATE PROCEDURE [dbo].[GetLicenseVerifiedRateWithAffiliate_ReportDetails_Doug]     
 -- Add the parameters for the stored procedure here    
-- DECLARE
   @Startdate date,-- = '05/01/2019' ,    
   @Enddate date,-- = '05/20/2019',    
   @AffiliateId int = 0,
   --@Affiliate varchar(50) = '',    
   @Clno as smallint = 0,    
   @LicenseState as varchar(8) =''    
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
    
    -- Insert statements for procedure here    
 SELECT   
 --ISNULL(convert(varchar(10), A.ApDate, 101) + right(convert(varchar(32), A.ApDate,100),8),'N/A') as 'Report Date',  
 FORMAT(a.Apdate,'MM/dd/yyyy hh:mm tt') as 'Report Date',  
 --A.ApDate AS 'Report Date',  
 A.APNO AS 'Report Number', R.Affiliate, A.CLNO as 'Client Number', C.Name AS 'Client Name',    
      A.[ApStatus] as 'Report Status',     
   ISNULL(FORMAT(a.ReOpenDate,'MM/dd/yyyy hh:mm tt'),'N/A') as 'Re-Open Date',    
      A.[Last] AS 'Last Name',A.[First] AS 'First Name',     
         P.Lic_Type_V AS 'License Type',P.State_V AS 'License State',P.Lic_No_V as LicenseNumber,S.[Description] AS 'Status'    
    
  FROM Appl A    
       INNER JOIN ProfLic P ON A.APNO = P.Apno     
       INNER JOIN Client C ON A.CLNO = C.CLNO    
       INNER JOIN refAffiliate R ON R.AffiliateID = C.AffiliateID    
       INNER JOIN SectStat S ON S.Code = P.SectStat    
  WHERE  (convert(date,P.[Last_Worked]) >= @Startdate)     
  AND (convert(date,P.[Last_Worked]) <= @Enddate)     
  AND (convert(date,P.[CreatedDate]) >= @Startdate) AND (convert(date,P.[CreatedDate]) <= @Enddate)     
  AND (P.IsOnReport = 1)    
  AND P.IsHidden = 0    
  AND (C.AffiliateId = @AffiliateId or @AffiliateId = 0)--R.AffiliateID = COALESCE(@AffiliateId,R.AffiliateID) 
  --AND R.Affiliate LIKE '%' + LTRIM(RTRIM(@Affiliate)) + '%' --OR @Affiliate = '')    
  --AND R.Affiliate = LTRIM(RTRIM(@Affiliate))    
  AND (A.CLNO = @Clno or @Clno = 0)    
  AND (P.State_V = @LicenseState OR @LicenseState ='')    
    
END 