
Create Proc dbo.FormAdverseContactFind_Apno
@ssn varchar(11)
as
declare @ErrorCode int

declare @cnt1 int
declare @cnt2 int
declare @cnt int

Begin Transaction
Set @ErrorCode=@@Error

set @cnt1=(select count(aa.apno)
	     from adverseaction aa,adversecontactlog acl,appl appl
	    where appl.ssn=@ssn
  	     and  aa.apno=appl.apno
  	     and  aa.adverseactionid=acl.adverseactionid
	   )
Set @cnt2=(select count(apno)
	     from appl appl
	    where appl.ssn=@ssn
          ) 

if (@cnt1=0 and @cnt2=0)
 begin
  set @cnt=-99
 end

if (@cnt1!=0 or @cnt2!=0)
 begin
  set @cnt=-1
 end
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@cnt)


