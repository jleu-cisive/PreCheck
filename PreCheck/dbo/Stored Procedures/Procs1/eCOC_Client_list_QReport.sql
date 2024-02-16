-- =============================================  
-- Author:  Radhika Dereddy  
-- Create date: 07/24/2019  
-- Description: Create a Stored Procedure instead an inline query  
-- Modified by Radhika dereddy on 07/24/2019 to incluse the PackageID  
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
*/  
--=============================================
CREATE PROCEDURE dbo.eCOC_Client_list_QReport   
   
 @CLNO varchar(1000)  
 ,@AffiliateID Varchar(Max)   -- Added on the behalf for HDT #56320  
AS  
BEGIN  
  
 SET NOCOUNT ON;  

	IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320  
	 Begin      
	  SET @AffiliateID = NULL      
	 END
    
 SELECT CC.CLNO,Name ClientName, Location, ProdCat, ProdClass, SpecType, Customer, PackageID   
 FROM  DBO.ClientConfiguration_DrugScreening CC   
 INNER JOIN DBO.Client C on CC.CLNO = C.CLNO    
 Where (CC.CLNO in (Select value from dbo.fn_Split(@CLNO,':')) or @CLNO ='0') 
 AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320 

END  