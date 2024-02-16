
CREATE Proc dbo.FormAdverseContactInfo_CheckContactInfo
@apno int,
@clno int,
@contactname varchar(50)
As
Declare @ErrorCode int
declare @cnt1 int
declare @cnt2 int
declare @cnt int

Begin Transaction
Set @ErrorCode=@@Error

if @clno=0 --for applicant
begin
 set @cnt1=(select count(ac.adversecontactid) 
	     from adversecontact ac,adversecontactlog acl,adverseaction aa,appl a 
	    where ac.adversecontactid=acl.adversecontactid
	      and acl.adverseactionid=aa.adverseactionid
	      and aa.apno=a.apno
                   and ac.clno=0 
	      and ac.contactname=@contactname 
                   and a.ssn=(select ssn from appl where apno=@apno)
	    )
 set @cnt=@cnt1
end
else --@clno!=0 for client
begin
 set @cnt2=(select count(adversecontactid) from adversecontact where clno=@clno and contactname=@contactname)
 set @cnt=@cnt2
end
          
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@cnt)
