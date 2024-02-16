

-- =============================================      

-- Author:  Douglas DeGenaro      

-- Create date: 11/21/2012      

-- Description: Returns Image file names and paths by apno      

-- =============================================      

      

--dbo.PrecheckFramework_GetImagePathsByApno 2101787      

--drop procedure [dbo].[PrecheckFramework_GetImagePathsByApno] 

CREATE PROCEDURE [dbo].[PrecheckFramework_GetImagePathsByApno_bkp2]       

 -- Add the parameters for the stored procedure here      

 @apno int        

AS      

BEGIN       

 -- SET NOCOUNT ON added to prevent extra result sets from      

 -- interfering with SELECT statements.      

 SET NOCOUNT ON;      

      

    -- Insert statements for procedure here       

 SELECT apno,ReleaseFormId,       

 ImageFilename,[Path] BasePath,ApnoFolder,QRY.SubFolder,[Description],SSN,SearchRoot      

 FROM      

 (      

 SELECT        

   afile.apno,      

   null as ReleaseFormId,      

   ISNULL(afile.ImageFilename,'') AS ImageFilename,        

   ISNULL(FilePath,'') AS Path,      

   cast((afile.apno/ 10000) * 10000 as varchar) AS ApnoFolder,      

   ISNULL(SubFolder,'') AS SubFolder,      

   ISNULL(afile.Description,'') as Description,  

   null as ssn,
   
   afloc.SearchRoot           

 FROM ApplFileLocation afloc (NOLOCK) JOIN ApplFile afile (NOLOCK)      

 ON afloc.refApplTypeID = afile.refApplFileType       

 WHERE Deleted = 0       

 UNION ALL      

 SELECT  apno,      

  null as ReleaseFormId,      

  images.ImageFilename,          

   ISNULL(FilePath,'') AS Path,      

   cast((images.apno/ 10000) * 10000 as varchar) as ApnoFolder,      

   ISNULL(SubFolder,'') AS SubFolder,      

   ISNULL(images.Description,'') as Description,  

   null as ssn,
   
   afloc.SearchRoot      

   FROM ApplFileLocation afloc (NOLOCK)       

    JOIN ApplImages images (NOLOCK) on afloc.refApplTypeID = 5      

   where IsNull(images.ImageFilename,'') <> ''      

 UNION ALL      

 select top 1 @apno as apno,ReleaseFormId,cast(@apno as varchar) + '_Release.pdf' as ImageFilename,null as Path,null as ApnoFolder,null as SubFolder,null as Description,R.ssn,cast(1 as bit) as SearchRoot      

 from dbo.ReleaseForm R inner join DBO.Appl A on R.CLNO = A.CLNO and (R.SSN = A.SSN or R.ClientAPPNO = A.ClientAPNO or R.ClientAPPNO = A.ClientApplicantNO) where A.apno = @apno order by releaseformid desc      

 ) QRY      
  
 WHERE QRY.apno = @apno      
 Group By QRY.apno,QRY.ReleaseFormId, QRY.ImageFilename,QRY.[Path] ,QRY.ApnoFolder,QRY.SubFolder,QRY.[Description],SSN,SearchRoot
 ORDER BY ImageFilename ASC      

      

END 
