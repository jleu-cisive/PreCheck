
Create Proc dbo.sp_FormAdverseEmailSaved
(@AETID int,
 @From varchar(100),
 @Subject1 varchar(100),
 @Subject2 varchar(100),
 @Body1 varchar(500),
 @Body2 varchar(500)
 )
As
Declare @ErrorCode int
Declare @AdverseEmailTemplateID int 

Begin Transaction
Set @ErrorCode=@@Error

--Modify AdverseEmailTemplate for contents changed
update AdverseEmailTemplate
set [from]=@From,
    Subject1=@Subject1,
    Subject2=@Subject2,
    Body1=@Body1,
    Body2=@Body2
where AdverseEmailTemplateID=@AETID
          
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)

