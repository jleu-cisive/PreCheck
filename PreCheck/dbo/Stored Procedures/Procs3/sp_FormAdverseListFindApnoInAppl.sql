Create Proc dbo.sp_FormAdverseListFindApnoInAppl
@apno int
As
Declare @ErrorCode int
Declare @cnt int
Begin Transaction
Set @ErrorCode=@@Error
Set @cnt = (select count (apno)
	    from   Appl
	    where  apno=@apno
  	    )            
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@cnt)
