
Create Proc dbo.sp_FormAdverseConfirmPrinted
(@AAID int,
 @UserId char(10)
 )
As
Declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

--Add new record in AdverseActionHistory - Amend Printed
Insert AdverseActionHistory Values(@AAID,14,@UserId,null,null,getdate())

--Modify AdverseAction for status
update AdverseAction
set StatusID=14
where AdverseActionID=@AAID
          
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  --Return (@@Identity)

