
Create Proc dbo.FormAdverseConfirmComm_Update
 @id int,
 @comm nvarchar(2000)
 
as
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

update MiscData
	set AmendComment=@comm
	where MiscDataID=@id
                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction


