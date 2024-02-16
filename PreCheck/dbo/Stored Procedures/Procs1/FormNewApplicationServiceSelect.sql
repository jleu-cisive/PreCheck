CREATE Proc [dbo].[FormNewApplicationServiceSelect]
@packageid int
as
declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select IncludedCount, MaxCount, ServiceName from packageservice aa  inner join  defaultrates bb
 on (aa.serviceid = bb.serviceid) where packageid =@packageid;

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction