CREATE Proc dbo.FormAdverseContactList_ContactHistory
@apno int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

   select ac.adversecontactid as acid,acl.adverseactionid as aaid,ac.contactname,
          ac.workphone,ac.workext,ac.homephone,ac.cellphone,ac.email,
          ac.adversecontacttypeid as actid,refact.adversecontacttype as contacttype
FROM adversecontactlog acl INNER JOIN adverseaction aa ON acl.adverseactionid = aa.adverseactionid INNER JOIN adversecontact ac ON acl.adversecontactid = ac.adversecontactid LEFT OUTER JOIN refadversecontacttype refact ON ac.adversecontacttypeid = refact.adversecontacttypeid
WHERE aa.apno=@apno

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction