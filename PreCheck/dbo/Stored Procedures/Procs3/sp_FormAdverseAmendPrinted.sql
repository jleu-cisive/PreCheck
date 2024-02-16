
Create Proc dbo.sp_FormAdverseAmendPrinted
(@AAID int,
 @UserId char(10)
 )
As
Declare @ErrorCode int
Declare @AdverseActionHistoryID int 

Begin Transaction
Set @ErrorCode=@@Error

--Add new record in AdverseActionHistory - Amend Printed
Insert AdverseActionHistory Values(@AAID,11,@UserId,null,null,getdate())
--Select @AdverseActionHistoryID=@@Identity

--Modify AdverseAction for status
update AdverseAction
set StatusID=11
where AdverseActionID=@AAID
          
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@@Identity)

