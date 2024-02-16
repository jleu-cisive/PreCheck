CREATE Proc dbo.FormAdverseContactInfo
@acid int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

   select distinct ac.adversecontactid as acid,aa.adverseactionid as aaid,aa.apno,appl.ssn,
	  aa.[name] as applicant,ac.contactname,ac.workphone,ac.workext,
 	  ac.homephone,ac.cellphone,ac.email,
          appl.clno,c.[name] as client,
          ac.adversecontacttypeid as actid,refact.adversecontacttype as contacttype        
FROM adverseaction aa INNER JOIN adversecontactlog acl ON aa.adverseactionid = acl.adverseactionid INNER JOIN adversecontact ac ON acl.adversecontactid = ac.adversecontactid INNER JOIN appl appl ON aa.apno = appl.apno INNER JOIN client c ON appl.clno = c.clno LEFT OUTER JOIN refadversecontacttype refact ON ac.adversecontacttypeid = refact.adversecontacttypeid
WHERE ac.adversecontactid = @acid

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction