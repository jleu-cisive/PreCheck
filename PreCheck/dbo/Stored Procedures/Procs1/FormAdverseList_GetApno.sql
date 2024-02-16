
Create Proc dbo.FormAdverseList_GetApno
@apno int
As
Declare @ErrorCode int
declare @cnt1 int
declare @cnt2 int
declare @cnt int

Begin Transaction
Set @ErrorCode=@@Error

set @cnt1=(select count (apno)
	     from adverseaction 
	    where apno=@apno
  	   )  
 
set @cnt2=(select count (apno)  
	     from adverseaction
	    where apno=@apno
	      and statusid not in (2,18,19)
	   )

if @cnt1=0
 begin
   set @cnt=-1  --apno doesn't exist
 end

if @cnt2!=0 
 begin
   set @cnt=0   --apno exists but in the datagrid
 end

if @cnt1!=0 and @cnt2=0
 begin
   set @cnt=1  --good apno
 end
       
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@cnt)

