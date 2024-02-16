
Create Proc dbo.FormAdverseContactList_Check
@apno int
as
declare @ErrorCode int
declare @cnt int
declare @cnt1 int

Begin Transaction
Set @ErrorCode=@@Error

--check if the apno exists in the adversecontact table
set @cnt1=(select count (acl.adverseactionid) 
            from adversecontactlog acl,adverseaction aa
	   where aa.apno=@apno
  	     and acl.adverseactionid=aa.adverseactionid
          )

if @cnt1=0
 begin
   set @cnt=-1
 end

else
 begin
   set @cnt=@cnt1
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


