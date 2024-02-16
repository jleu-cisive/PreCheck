-- =============================================    
-- Author:  <Lalit,Kumar>    
-- Create date: <11/30/2023>    
-- Description: <used to get releaseform for criminal searches that will be send to the vendor>   
-- [IWS_FindOnlineRelease] 7720814  
-- modifed by lalit on 14/dec/2023 for Studentcheck
-- =============================================    
CREATE PROCEDURE [dbo].[IWS_FindOnlineRelease_Crim]    
 -- Add the parameters for the stored procedure here    
 @APNO int    
AS    
BEGIN    
  --declare @APNO int=7720814--7720814--7740116 --7231826   -- disable this  
  
  DECLARE @social varchar(20),@id int,@clientid int,@apdate datetime;    
  DECLARE @gaccount INT  
     DECLARE @releaseformoasis int  
     set @gaccount=(SELECT TOP 1 c.CrimID from dbo.Crim c WITH(NOLOCK) INNER join dbo.CountiesReleaseRequirement crr WITH(NOLOCK) ON c.CNTY_NO=crr.CNTY_NO AND c.APNO=@APNO AND c.IsHidden<>1)      
     
     ------------------------------  
    set @releaseformoasis=(select TOP 1 ApplFileID from applfile where apno = @APNO and refapplfiletype = 1 and deleted = 0 AND AttachToReport IS NULL  
  AND ImageFilename LIKE '%GA_Consent%' AND   ImageFilename NOT LIKE '%_RA_%' ORDER BY CreatedDate desc)  
 if (@releaseformoasis>0 and @gaccount is not null)  
  begin  
    SELECT NULL as pdf;    
  end  
 ELSE  
 BEGIN  
  ------------------------------    
   DECLARE @ApplicantFormId int    
   DECLARE @FormNumberNew varchar(10)
   SET @ApplicantFormId=(SELECT TOP 1 aef.ApplicantFormId    
        FROM Enterprise.dbo.Applicant a WITH(NOLOCK)    
        INNER JOIN Enterprise.dbo.ApplicantExternalForm aef WITH(NOLOCK) ON a.ApplicantId=aef.ApplicantId AND aef.ModifyDate>a.CreateDate AND aef.IsLocked=1-- AND len(aef.AlternativeFileContent)>100    
        INNER JOIN Enterprise.[External].Form ef WITH(NOLOCK) ON aef.FormId=ef.FormId AND FormNumber IN ('SF_GA_01','SF_GA_02')
        WHERE a.ApplicantNumber=@APNO--7231826--7231800     
        ORDER BY aef.CreateDate DESC)    
   SET @ApplicantFormId=(SELECT TOP 1 ApplicantFormId    
        FROM Enterprise.dbo.ApplicantExternalForm aef WITH(NOLOCK)    
        WHERE aef.ApplicantFormId=@ApplicantFormId AND LEN(aef.AlternativeFileContent)>100)--(len(aef.AlternativeFileContent)>100 or DATEDIFF(MINUTE,CreateDate,getdate())>50) )  -- enable this to limit external form to certtain time    
  
  if(@ApplicantFormId is not null)    
   begin    
     SELECT aef.AlternativeFileContent AS pdf    
     FROM Enterprise.dbo.ApplicantExternalForm aef WITH(NOLOCK)    
     WHERE aef.ApplicantFormId=@ApplicantFormId --AND len(aef.AlternativeFileContent)>100    
    END    
  ---------------------------------  
  ELSE  
   BEGIN  
    --DECLARE @gaccount INT  
    --set @gaccount=(SELECT TOP 1 c.CrimID from dbo.Crim c WITH(NOLOCK) INNER join dbo.CountiesReleaseRequirement crr WITH(NOLOCK) ON c.CNTY_NO=crr.CNTY_NO AND c.APNO=@APNO AND c.IsHidden<>1)  
    --select @gaccount crimid -- disable this  
     
    if(@gaccount IS not NULL)  
     BEGIN  
      SELECT NULL as pdf;    
     END  
    ELSE  
     BEGIN  
      SELECT @social = ssn, @clientid = clno,@apdate = dateadd(month,2,apdate) from appl where apno = @APNO;    
    
      SET @id = (select top 1 releaseformid from releaseform WITH(NOLOCK) where ssn = @social and [date]<=@apdate    
        and (ReleaseForm.clno = @clientid    
        or ReleaseForm.clno in    
        (Select clno from ClientHierarchyByService where    
         parentclno=(select parentclno from ClientHierarchyByService where clno =@clientid and refHierarchyServiceID=2)    
         and refHierarchyServiceID=2))    
         order by date desc);    
      --select @social ssn -- disable this  
       
      if(@id is not null)    
        SELECT pdf from releaseform WITH(NOLOCK) where releaseformid = @id;    
    
      ELSE    
       BEGIN    
         SET @id = (select top 1 releaseformid from Precheck_MainArchive.dbo.ReleaseForm_Archive R WITH(NOLOCK) where ssn = @social  and [date]<=@apdate    
        and (R.clno = @clientid    
        or R.clno in    
        (Select clno from ClientHierarchyByService where    
         parentclno=(select parentclno from ClientHierarchyByService where clno =@clientid and      refHierarchyServiceID=2)))    
         order by date desc);     
    
       if(@id is not null)    
        SELECT pdf from Precheck_MainArchive.dbo.ReleaseForm_Archive WITH(NOLOCK) where releaseformid = @id;    
       ELSE    
        SELECT NULL as pdf;    
       END   
     end  
   END  
  END  
  
END 