
CREATE PROCEDURE [dbo].[FormAdverseFileOpen_CheckDispute] 
@fileOpenLogId int,
@newDispute bit
AS
declare @oldDispute bit
declare @checkValue int

select @oldDispute=Dispute
  from adversefileopenlog
 where AdverseFileOpenLogID=@fileOpenLogId

if @oldDispute!=@newDispute
  begin
    set @checkValue=1
  end
else
  begin 
   set @checkValue=0
  end

return @checkValue



