
Create Proc dbo.FormAdverseContactInfo_FillEditInfo
@acid int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select acl.adverseactionid as aaid,aa.[name] as applicant,
       ac.clno,ac.contactname,ac.workphone,ac.workext,
       ac.homephone,ac.cellphone,ac.email,ac.adversecontacttypeid as actid
  from adversecontact ac,adverseaction aa,adversecontactlog acl
 where ac.adversecontactid=@acid
   and aa.adverseactionid=acl.adverseactionid
   and acl.adversecontactid=ac.adversecontactid


Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
 

