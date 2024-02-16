    
-- =============================================    
-- Author:  Douglas DeGenaro    
-- Create date: 09/24/2012    
-- Description: Query to pull any orders where releaseflag is set, using section    
-- =============================================    
--dbo.Verification_GetReleaseAvailable null  
CREATE PROCEDURE [dbo].[Verification_GetReleaseAvailable]     
 -- Add the parameters for the stored procedure here    
 @vendor varchar(30) = null  
AS    
DECLARE @webStatReleaseFlag int    
    
-- Set to release available flag, or create an entry in websectstat and point to that entry.    
set @webStatReleaseFlag = 66    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
 SET NOCOUNT ON;    
     
 if (IsNull(@vendor,'') = '')    
  set @vendor = 'REFPRO'    
  
--Added by Doug DeGenaro on 2/3/2014
SELECT tbl.Section,a.APNO,a.SSN as SSN,a.DOB as DOB,tbl.SectionId,tbl.OrderId,tbl.web_status,tbl.investigator FROM   
(  
 SELECT 'Employment' as Section,APNO,EmplId as SectionId,OrderId,web_status,investigator from dbo.Empl   
 UNION ALL  
 SELECT 'Education' as Section,APNO,EducatId as SectionId,OrderId,web_status,investigator from dbo.Educat) as tbl  
 join dbo.Appl a ON tbl.APNO = a.APNO
 WHERE tbl.web_status = @webStatReleaseFlag AND tbl.investigator = @vendor 

-- SELECT * FROM   
--(  
-- SELECT 'Employment' as Section,APNO,EmplId as SectionId,OrderId,web_status,investigator from dbo.Empl   
-- UNION ALL  
-- SELECT 'Education' as Section,APNO,EducatId as SectionId,OrderId,web_status,investigator from dbo.Educat) as tbl  
-- join dbo.Appl a ON tbl.APNO = a.APNO
-- WHERE tbl.web_status = @webStatReleaseFlag AND tbl.investigator = @vendor  
END