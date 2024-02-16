-- ============================================= 
/* Modified By: YSharma   
-- Modified Date: 10/18/2022  
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
CREATE Procedure [tobedeleted].[ECOCClientSetupInfo]
@CLNO int ,
@AffiliateID  Varchar(Max)='' -- Added on the behalf for HDT #56320   ;
As
Begin

  IF @CLNO=''  OR @CLNO=0					-- Condition Added after Requestor's Review
    BEGIN
        SET @CLNO=NULL
    END

  IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320  
	 BEGIN      
	  SET @AffiliateID = NULL      
	 END  

SELECT ccd.CLNO,c.Name,ccd.Location,ccd.ProdCat,ccd.ProdClass,ccd.SpecType 
FROM dbo.ClientConfiguration_DrugScreening ccd JOIN
dbo.Client c ON ccd.CLNO=c.CLNO 
WHERE ccd.CLNO=ISNULL(@CLNO,ccd.CLNO)
AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320 
End
