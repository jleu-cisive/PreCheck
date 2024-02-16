/* Modified By: YSharma 
-- Modified Date: 07/12/2022
-- Description: Ticketno-#55504 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*
EXEC [dbo].[AdverseActionActivityReportByClient] '3115','01/01/2021','06/06/2022','0' 
EXEC [dbo].[AdverseActionActivityReportByClient] '3115','01/01/2021','06/06/2022','4:30' 
*/
CREATE PROCEDURE [dbo].[AdverseActionActivityReportByClient]  
  
 @CLNO INT,  
 @StartDate DATE,  
 @EndDate DATE,   
@AffiliateID Varchar(Max)='0'									-- Added on the behalf for HDT #55504
 --@AffiliateID int = 0											-- Comnt for HDT #55504	
  
AS  
SET NOCOUNT ON  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
 
 IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #55504
 Begin    
  SET @AffiliateID = NULL    
 END 
  
SELECT A.APNO ReportNumber,c.clno, c.name, A.APDATE [Background Request Date],A.CompDate [Final Background Report Date],A.Last,First,AA.ClientEmail RequestedBy,  
AH.Date DateExecuted,s.[Status], rf.Affiliate, rf.AffiliateID, AA.ApplicantEmail,AA.Address1,AA.Address2,AA.City,AA.State,AA.Zip   
FROM precheck..AdverseAction AA   
INNER JOIN precheck..AdverseActionhistory AH ON AH.AdverseActionID = AA.AdverseActionID  
INNER JOIN precheck..APPL A ON A.APNO = AA.APNO  
INNER JOIN precheck..refAdverseStatus S ON AH.StatusID=s.refAdverseStatusID  
INNER JOIN Client c ON a.CLNO = c.CLNO  
INNER JOIN refAffiliate rf ON c.AffiliateID =  rf.AffiliateID  
WHERE c.clno = IIF(@CLNO=0,c.CLNO,@CLNO)  
AND AH.StatusID IN (1,5,30,16,18,31)   
AND CAST(AH.Date AS DATE) BETWEEN @StartDate AND @EndDate  
AND (@AffiliateID IS NULL OR rf.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #55504
   --AND rf.AffiliateID = IIF(@AffiliateID =0, rf.AffiliateID, @AffiliateID) 						-- Comnt for HDT #55504	 
  
ORDER BY A.APNO,AH.Date  
  
  
  
SET TRANSACTION ISOLATION LEVEL READ COMMITTED  
SET NOCOUNT OFF  