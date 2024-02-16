-- =============================================  
-- Author:  Humera Ahmed  
-- Create date: 2/20/2019  
-- Description: QReport that will locate all reports in our system that have an admitted or self-disclosed record.  
-- EXEC QReport_ReportsWithAdmittedRecords '10/01/2022','10/31/2022','0'  
-- Modified by Mainak Bhadra on 10/12/2022 to add AffiliateId for ticket #67224
-- EXEC QReport_ReportsWithAdmittedRecords '10/01/2022','10/31/2022','','10:4'
-- =============================================  
CREATE PROCEDURE [dbo].[QReport_ReportsWithAdmittedRecords]  
 -- Add the parameters for the stored procedure here  
 @StartDate datetime,  
 @EndDate datetime,  
 @CLNO VARCHAR(MAX) = '' ,
 @AffiliateId varchar(MAX) = '0'--code added by Mainak for ticket id -67224
AS  
BEGIN  


 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  

 --code added by Mainak for ticket id -67224 starts
	IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END
 --code added by Mainak for ticket id -67224 ends
  
    -- Insert statements for procedure here  
 SELECT    
  aad.apno [Report Number]  
  ,A.First [First Name]  
  ,A.Last [ Last Name]  
 ,A.ApDate [Created Date]  
 ,A.EnteredVia  
 ,A.Investigator  
 ,C.Name [Client Name]  
 ,A.CLNO [Client ID]  
 ,RA.Affiliate   
 ,A.UserID AS [Client's CAM]  
 ,CR.County  
 FROM appl A  
  INNER JOIN client C ON a.CLNO = C.CLNO  
  inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
  left JOIN dbo.ApplAdditionalData aad ON A.APNO = aad.APNO AND A.CLNO = aad.CLNO AND REPLACE(A.SSN, '-','')= REPLACE(aad.SSN, '-','')  
  left JOIN crim CR ON A.APNO = CR.APNO AND CR.AdmittedRecord=1  
 WHERE   
  aad.Crim_SelfDisclosed = 1  
  and A.ApStatus in ('P','W')  
  AND Isnull(A.Investigator, '') <> ''  
  AND A.userid IS NOT null  
  AND Isnull(A.CAM, '') = ''   
  AND a.ApDate>=@StartDate And a.Apdate<=dateadd(d,1,@EndDate)  
  AND (@CLNO ='' OR A.CLNO IN (SELECT value from [dbo].[fn_Split](@clno,':')))  
  AND (@AffiliateId IS NULL OR RA.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))--code added by Mainak for ticket id -67224
 GROUP BY aad.APNO, CR.APNO, A.ApDate  
 ,A.EnteredVia  
 ,A.Investigator  
 ,A.CLNO  
 ,C.Name   
 ,RA.Affiliate  
 ,A.UserID  
 ,A.First  
 ,A.Last  
 ,CR.County  
 ORDER BY A.CLNO, aad.APNO, A.apdate  
  
END  