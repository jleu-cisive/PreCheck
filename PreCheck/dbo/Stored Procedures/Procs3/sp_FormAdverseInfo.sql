
Create Proc dbo.sp_FormAdverseInfo
@AAID int
As
Declare @ErrorCode int

Begin Transaction
select distinct aa.AdverseActionID As AAID,aa.APNO,appl.CLNO,cl.[Name] As Client,
       appl.SSN As ApplicantSSN,aa.[name] As ApplicantName,
       aa.StatusID As StatusID,refas.Status As Status
from   AdverseAction aa,Appl appl,Client cl,refAdverseStatus refas
where  aa.AdverseActionID=@AAID
  and  aa.APNO=appl.APNO 
  and  appl.clno=cl.clno 
  and  aa.StatusID=refas.refAdverseStatusID
                    
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)

