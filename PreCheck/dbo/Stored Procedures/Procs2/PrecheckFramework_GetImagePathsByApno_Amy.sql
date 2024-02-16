

-- =============================================      
-- Author:  Douglas DeGenaro      
-- Create date: 11/21/2012      
-- Description: Returns Image file names and paths by apno   
-- Modiifed By: Amy Liu on 07/27/2021: fineTune-- added apno into union query to make it faster

--exec dbo.PrecheckFramework_GetImagePathsByApno 5945397  -- 5945395   --5420595  ---clno: 15989    --3818320      
-- =============================================      

create PROCEDURE [dbo].[PrecheckFramework_GetImagePathsByApno_Amy]           
 @apno int        
AS      

BEGIN       

 SET NOCOUNT ON; 

 --declare @apno int =5420595
 DECLARE @SSN varchar(11), @ClientApno varchar(50), @ClientApplicantNO varchar(50), @CLNO INT,@Last varchar(20),@First  varchar(20),@EnteredVia VARCHAR(10),@ApDate datetime

 SELECT @SSN =Replace(SSN,'-',''), @ClientApno = ClientAPNO, @ClientApplicantNO = ClientApplicantNO, @CLNO =CLNO,@Last = [Last],@First = [First],@EnteredVia = A.EnteredVia,@ApDate= ApDate
 FROM DBO.APPL A 
 Where APNO  = @apno

 --select @ssn '@ssn', @ClientApno '@ClientApno',@ClientApplicantNO '@ClientApplicantNO',@CLNO '@CLNO', @Last '@Last', @First '@First', @EnteredVia '@EnteredVia', @ApDate '@ApDate'
 --drop table if exists #tmpReleaseSharingclients 

	select chbs2.CLNO into #tmpReleaseSharingclients 
	from ClientHierarchyByService  chbs1
	inner join ClientHierarchyByService  chbs2 on  chbs1.ParentCLNO= chbs2. ParentCLNO
						where chbs1.clno =15989 and  -- @CLNO and      
						chbs1.refHierarchyServiceID=2 


 SELECT apno,ReleaseFormId,       

 ImageFilename,
 --'file:///' + [Path] BasePath,
 [Path] BasePath,
 ApnoFolder,QRY.SubFolder,[Description],SSN,SearchRoot,IsAppLevel      

 FROM      

 (      

 SELECT        

   afile.apno,      

   null as ReleaseFormId,      

  --ISNULL(afile.ImageFilename,'') AS ImageFilename,  
    isnull(afile.ImageFilename,cast(apno as varchar(20)) + '_' + raft.Description + '_' + afile.ClientFilename) ImageFileName,   
   

   ISNULL(FilePath,'') AS Path,      

   cast((afile.apno/ 10000) * 10000 as varchar) AS ApnoFolder,      

   ISNULL(SubFolder,'') AS SubFolder,      

   ISNULL(afile.Description,'') as Description,  

   null as ssn,
   
   afloc.SearchRoot,
   
   raft.IsAppLevel           

 FROM ApplFileLocation afloc (NOLOCK) 
 inner JOIN ApplFile afile (NOLOCK)  ON afloc.refApplTypeID = afile.refApplFileType       
 inner JOIN refApplFileType raft on afloc.refApplTypeID = raft.refApplFileTypeId
 WHERE Deleted = 0  
 and  afile.apno= @apno
 
 
 UNION ALL      

 SELECT  apno,      

  null as ReleaseFormId,      

  images.ImageFilename,          

   ISNULL(FilePath,'') AS Path,      

   cast((images.apno/ 10000) * 10000 as varchar) as ApnoFolder,      

   ISNULL(SubFolder,'') AS SubFolder,      

   ISNULL(images.Description,'') as Description,  

   null as ssn,
   
   afloc.SearchRoot,
   
   raft.IsAppLevel      

   FROM ApplFileLocation afloc (NOLOCK)       
    JOIN ApplImages images (NOLOCK) on afloc.refApplTypeID = 5      
	JOIN refApplFileType raft on afloc.refApplTypeID = raft.refApplFileTypeId
   where IsNull(images.ImageFilename,'') <> ''  
   and APNO=@apno

 UNION ALL      

 --Modified the below query by Schapyala on 03/18/14 --> Also including a last and first name match (only when App SSN is missing) with the CLNO's (hierarchy)
 Select Top 1 apno,ReleaseFormId,ImageFilename,[Path],ApnoFolder,SubFolder,[Description],ssn,SearchRoot,IsAppLevel 
 From ( Select Top 1 @apno as apno,ReleaseFormId,cast(RTRIM(Ltrim(@apno)) as varchar) + '_Release.pdf' as ImageFilename,null as [Path],null as ApnoFolder,null as SubFolder,null as [Description],R.ssn,cast(1 as bit) as SearchRoot,cast(1 as bit) as IsAppLevel   
		from dbo.ReleaseForm R Where R.CLNO = @CLNO AND (Replace(R.SSN,'-','') = @SSN or R.ClientAPPNO = @ClientAPNO or R.ClientAPPNO = @ClientApplicantNO or (@Last = R.[Last] AND @First = R.[First]  AND @SSN IS NULL))
		order by releaseformid desc
		UNION ALL
		select TOP 1 @apno as apno,ReleaseFormId,cast(RTRIM(Ltrim(@apno)) as varchar) + '_Release.pdf' as ImageFilename,null as [Path],null as ApnoFolder,null as SubFolder,null as [Description],R.ssn,cast(1 as bit) as SearchRoot,cast(1 as bit) as IsAppLevel      
		 from dbo.ReleaseForm R 
		 inner join #tmpReleaseSharingclients temp ON R.CLNO = temp.CLNO
		 Where (Replace(R.SSN,'-','') = @SSN or R.ClientAPPNO = @ClientAPNO or R.ClientAPPNO = @ClientApplicantNO or (@Last = R.[Last] AND @First = R.[First]  AND @SSN IS NULL)) 
		 order by releaseformid desc
	  ) Qry1

UNION ALL

SELECT Top 1 @apno apno,NULL AS ReleaseFormId,'Release Applicant Info' ImageFilename,'https://internal.precheck.com/PreEmp/Document/Get?report=' + cast(RTRIM(Ltrim(@apno)) as varchar) + '&name=' + REPLACE(@Last, ' ', '%20') + '&dummy=' [Path],NULL ApnoFolder,NULL SubFolder,'Applicant_info' [Description],@SSN ssn,cast(1 as bit) as SearchRoot,cast(1 as bit) as IsAppLevel   
WHERE (@EnteredVia = 'CIC' or (@EnteredVia = 'stuweb' and @ApDate> '10/01/2017 21:00')) -- studentcheck cutover to CIC platform at that time

UNION ALL 

Select Top 1 @apno apno,NULL AS ReleaseFormId,'XML Data Points' ImageFilename,'https://weborder.precheck.net/ShowDataPoints/WebForm1.aspx?apno=' + cast(RTRIM(Ltrim(@apno)) as varchar)  + '&dummy=' [Path],NULL ApnoFolder,NULL SubFolder,'XML' [Description],@SSN ssn,cast(1 as bit) as SearchRoot,cast(1 as bit) as IsAppLevel 
FROM enterprise..[Order] WHERE OrderNumber= @apno  
and @EnteredVia in ('CIC') 
AND IntegrationRequestId IS NOT NULL

 ) QRY      
  
 WHERE QRY.apno = @apno      
 Group By QRY.apno,QRY.ReleaseFormId, QRY.ImageFilename,QRY.[Path] ,QRY.ApnoFolder,QRY.SubFolder,QRY.[Description],SSN,SearchRoot,QRY.IsAppLevel
 ORDER BY ImageFilename ASC      

      

END 
