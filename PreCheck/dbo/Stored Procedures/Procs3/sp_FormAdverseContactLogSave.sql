
Create Proc dbo.sp_FormAdverseContactLogSave
(@Aaid int,
 @StatusID int,
 @UserId char(10),
 @ACMId int,
 @Comment text
 )
As
Declare @ErrorCode int
Declare @AdverseActionHistoryID int 

Begin Transaction
Set @ErrorCode=@@Error

--Add new record in AdverseActionHistory
Insert into AdverseActionHistory (AdverseActionID,StatusID,UserID,AdverseContactMethodID,Comments,[Date])
    Values(@AAID,@StatusID,@UserId,@ACMId,@Comment,getdate())
Select @AdverseActionHistoryID=@@Identity
         
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (@@Identity)

