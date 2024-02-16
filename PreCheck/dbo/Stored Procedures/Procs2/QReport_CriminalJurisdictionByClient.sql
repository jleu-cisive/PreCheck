-- =============================================    
-- Author:  YSharma    
-- Create date: 07/11/2022    
-- Description: As HDT #56320 required multipule Affiliate IDs in Qreport So I am making changes in the same.   

-- Modify Date: 2/2/2023
-- Modify By : YSharma
-- Description: Condition added after requestor's Review. When CLNO is 0 then it should give result for all.
-- Execution:     
/*    
EXEC dbo.QReport_CriminalJurisdictionByClient '04/20/2014','04/29/2014','5751','4:257'    
  
*/    
-- =============================================   
CREATE Procedure dbo.QReport_CriminalJurisdictionByClient  
(  
@StartDate datetime,    
@Enddate datetime,    
@CLNO int ,  
@AffiliateID  Varchar(Max)=''   -- Added on the behalf for HDT #56320   ;   
  
)  
AS  
BEGIN  
  
  IF @CLNO=''  OR @CLNO=0					-- Condition Added after Requestor's Review
    BEGIN
        SET @CLNO=NULL
    END
  
IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320    
  BEGIN        
   SET @AffiliateID = NULL        
  END    
  
SELECT      A.APNO, C.County, C.CNTY_NO, cl.Name as ClientName    
FROM         dbo.Crim C     
INNER JOIN  dbo.Appl A on C.APNO = A.APNO    
INNER JOIN  dbo.Client Cl on A.CLNO = Cl.CLNO    
WHERE (A.Apdate between @StartDate and @Enddate)   
AND A.CLNO  =ISNULL(@CLNO,A.CLNO)  
AND (@AffiliateID IS NULL OR Cl.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320   
  
END