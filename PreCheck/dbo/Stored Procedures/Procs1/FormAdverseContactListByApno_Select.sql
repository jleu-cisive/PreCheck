CREATE Proc dbo.FormAdverseContactListByApno_Select
 @apno int
as
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select ac.adversecontactid as acid,acl.adverseactionid as aaid,aa.apno,
       ac.contactname,ac.workphone,ac.workext,ac.homephone,ac.cellphone,ac.email,
       ac.adversecontacttypeid as actid,refact.adversecontacttype as contacttype
FROM adverseaction aa INNER JOIN adversecontactlog acl ON aa.adverseactionid = acl.adverseactionid INNER JOIN adversecontact ac ON acl.adversecontactid = ac.adversecontactid LEFT OUTER JOIN refadversecontacttype refact ON ac.adversecontacttypeid = refact.adversecontacttypeid
WHERE aa.apno=@apno
 order by acid desc

if (@errorCode<>0)
  begin
  rollback transaction
  return (-@ErrorCode)
  end
else
  commit transaction