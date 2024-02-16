-- =============================================    
-- Author:  YSharma    
-- Create date: 07/11/2022    
-- Description: As HDT #56320 required Affiliate IDs in Qreport So I am making changes in the same.   

-- Modify Date: 2/2/2023
-- Modify By : YSharma
-- Description: Condition added after requestor's Review. When CLNO is 0 then it should give result for all.
-- Execution:     
/*    
EXEC dbo.QReport_ClientPackageDetails '0','4:257'    
  
*/    
-- =============================================   
CREATE Procedure dbo.QReport_ClientPackageDetails  
(  
@CLNO as Int ='0',  
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
  
Select c.CLNO, c.Name as ClientName, pm.PackageDesc as PackageName, pm.DefaultPrice, cp.Rate as Price  
, rf.Description as RateType, ps.IncludedCount, ps.MaxCount, dr.DefaultRate as DefaultRate    
from dbo.ClientPackages cp     
inner join dbo.client c on cp.CLNO = c.CLNO    
inner Join dbo.PackageMain pm on cp.PackageID = pm.PackageID    
inner join dbo.PackageService ps on pm.PackageID = ps.PackageID    
inner join dbo.refServiceType rf on ps.ServiceType= rf.ServiceType    
inner join dbo.DefaultRates dr on  ps.ServiceID = dr.ServiceID    
where c.CLNO = ISNULL(@CLNO,c.CLNO)    
AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT #56320  
  
END