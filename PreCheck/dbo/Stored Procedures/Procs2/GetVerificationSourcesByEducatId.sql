

-- =============================================  
-- Author:  Prasanna 
-- Create date: 07/02/2019  
-- Description: To pull education detail based on education id (Based on #53875 created this procedure to avoid cross reference)
-- Execution: exec GetVerificationSourcesByEducatId 3384488  
-- =============================================  
CREATE PROCEDURE [dbo].[GetVerificationSourcesByEducatId]  
 @Educatld int  
  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
 SELECT  SectionKeyID, refVerificationSource, SourceVerifyType, SourceVerifyName,   
   VerificationSourceCode = STUFF((SELECT ',' + VerificationSourceCode  
           FROM Integration_Verification_SourceCode AS x2(NOLOCK)  
           WHERE SectionKeyID = @Educatld  
           GROUP BY SectionKeyID, VerificationSourceCode  
           ORDER BY SectionKeyID DESC  
           FOR XML PATH('')), 1, 1, '')  
 FROM Integration_Verification_SourceCode AS x(NOLOCK)  
 INNER JOIN educat e ON x.SectionKeyID = e.EducatID
 WHERE VerificationSourceCode IS NOT NULL   
   AND VerificationSourceCode <> ''   
   AND SectionKeyID = @Educatld  AND isnull(x.SourceVerifyType, '') <> ''
 GROUP BY SectionKeyID, refVerificationSource, SourceVerifyName, SourceVerifyType  
  
END  
  
  