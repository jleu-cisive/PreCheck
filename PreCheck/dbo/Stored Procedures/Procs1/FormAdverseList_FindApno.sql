
Create Proc dbo.FormAdverseList_FindApno
@apno int
As
Declare @ErrorCode int
declare @cnt1 int
declare @cnt2 int
declare @cnt int

Begin Transaction
Set @ErrorCode=@@Error

Set @cnt1 = (select count (apno)
	    from   AdverseAction 
	    where  apno=@apno
  	    )  

Set @cnt2 = (select count (apno)
	    from   Appl
	    where  apno=@apno
  	    )  

if (@cnt2=0)
  begin
	set @cnt=-1
  end 

if (@cnt1!=0)
 begin
	set @cnt=1
 end

if (@cnt1=0 and @cnt2!=0)
 begin
	set @cnt=2
 end
       
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@cnt)

