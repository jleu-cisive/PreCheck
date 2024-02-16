-- =============================================    
-- Author:  YSharma    
-- Create date: 07/11/2022    
-- Description: As HDT #56320 required Affiliate IDs in Qreport So I am making changes in the same.   

-- Modify Date: 2/2/2023
-- Modify By : YSharma
-- Description: Condition added after requestor's Review. When CLNO is 0 then it should give result for all.
-- Execution:     
/*    
EXEC dbo.QReport_ApplicantDataByCLNOAndDateRange '1/1/2022','1/30/2022','2167',''    
  
*/    
-- =============================================   
CREATE Procedure dbo.QReport_ApplicantDataByCLNOAndDateRange   
(  
 @StartDate DateTime    
   ,@EndDate DateTime    
   , @CLNO Int   
   ,@AffiliateID Varchar(Max)=''   -- Added on the behalf for HDT #56320   ;  
)  
AS  
BEGIN  
    
	IF @CLNO=''  OR @CLNO=0					-- Condition Added after Requestor's Review
    BEGIN
        SET @CLNO=NULL
    END

   IF(@AffiliateID = '' OR LOWER(@AffiliateID) = 'null' OR @AffiliateID = '0')   -- Added on the behalf for HDT #56320    
   Begin        
    SET @AffiliateID = NULL        
   END    
   SELECT A.CLNO, C.[Name] ClientName, First, Last, Middle, SSN, DOB, ApDate, CP.[Name] ProgramName,PackageDesc   
   from DBO.Appl A (nolock)   
   inner join DBO.Client C (NOLOCK) on A.CLNO = C.CLNO  
   left join DBO.clientProgram CP (NOLOCK) ON A.CLNO = CP.CLNO AND A.ClientProgramID = CP.ClientProgramID  
   left join DBO.PackageMain PM (NOLOCK) ON  A.PackageID = PM.PackageID    
   Where A.CLNO = ISNULL(@CLNO,A.CLNO)
   AND   A.ApDate between @StartDate AND @EndDate  
   AND (@AffiliateID IS NULL OR C.AffiliateID in (SELECT value FROM fn_Split(@AffiliateID,':'))) -- Added on the behalf for HDT  
END