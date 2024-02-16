-- =============================================    
-- Author:  kmiryala    
-- Create date: 1-14-2011    
-- Description: this is similar to Q report MD Anderson by StartDate which can be used for any client by passing CLNO and start date    
-- =============================================    
/* Modified By: YSharma     
-- Modified Date: 07/11/2022    
-- Description: Ticketno-#56320     
Modify existing q-reports that have affiliate ids in their search parameters    
Details:     
Change search parameters for the Affiliate Id field    
     * search by multiple affiliate ids (ex 4:297)    
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates    
     * multiple affiliates to be separated by a colon      
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

-- Modify Date: 2/2/2023
-- Modify By : YSharma
-- Description: Condition added after requestor's Review. When CLNO is 0 then it should give result for all.
*/    
--=============================================  
CREATE PROCEDURE dbo.[ClientByStartDate]    
@clno int,     
@StartDate datetime,    
@AffiliateID Varchar(Max)   -- Added on the behalf for HDT #56320   
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    

 
  IF @CLNO=''  OR @CLNO=0					-- Condition Added after Requestor's Review
    BEGIN
        SET @CLNO=NULL
    END

IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320    
 Begin        
  SET @AffiliateID = NULL        
 END     
    
    
 SELECT  A.apno AS 'Report Number',A.apstatus AS 'Report Status',A.last AS 'Last Name',A.first AS 'First Name',    
 A.ssn AS SSN,A.attn AS Recruiter, A.apdate AS 'Date Submitted',A.compdate AS 'Date Completed'    
 FROM appl A  
  INNER JOIN Client C On A.CLNO=C.Clno  
  WHERE A.startdate = @StartDate   
  AND A.clno =ISNULL(@clno ,A.CLNO)
  AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320   
    
END    
  
    