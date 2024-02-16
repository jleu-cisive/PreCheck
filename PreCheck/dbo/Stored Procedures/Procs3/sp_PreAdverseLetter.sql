
Create Proc dbo.sp_PreAdverseLetter
  @AAID int
As
Declare @ErrorCode int

Begin Transaction
select aa.AdverseActionID As AAID,acl.ApplicantName As Applicant,
       aa.Address1 As Addr1,aa.Address2 As Addr2,aa.City,aa.State,aa.Zip,
       acl.EmployerName As Employer,u.[Name] As UserName
from   AdverseAction aa,AdverseContactLog acl,Users u
where  aa.AdverseActionID=@AAID and 
       aa.AdverseActionID=acl.AdverseActionID and 
       acl.UserID=u.UserID
             
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)

