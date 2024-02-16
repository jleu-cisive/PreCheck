-- =============================================  
-- Author:  Bernie Chan  
-- Create date: 10/23/2014  
-- Description: Change multiple row into one single row for Verification Source Code for a specific employee  
-- Execution: exec GetVerificationSourcesByEmpId 5124139  
-- =============================================  
CREATE PROCEDURE [dbo].[GetVerificationSourcesByEmpId_Prasanna]  
 @Empld int  
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 SELECT  SectionKeyID, refVerificationSource, SourceVerifyType, SourceVerifyName,   
   VerificationSourceCode = STUFF((SELECT ',' + VerificationSourceCode  
           FROM Integration_Verification_SourceCode AS x2(NOLOCK)  
           WHERE SectionKeyID = @Empld  
           GROUP BY SectionKeyID, VerificationSourceCode  
           ORDER BY SectionKeyID DESC  
           FOR XML PATH('')), 1, 1, '')  
 FROM Integration_Verification_SourceCode AS x(NOLOCK)  
 WHERE VerificationSourceCode IS NOT NULL   
   AND VerificationSourceCode <> ''   
   AND SectionKeyID = @Empld  
 GROUP BY SectionKeyID, refVerificationSource, SourceVerifyName, SourceVerifyType  
  
END  
  
  
  