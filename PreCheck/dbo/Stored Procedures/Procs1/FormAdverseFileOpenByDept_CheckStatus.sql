
CREATE PROCEDURE [dbo].[FormAdverseFileOpenByDept_CheckStatus] 
@fileOpenLogId int,
@newAmended bit,
@newConfirmed bit
AS
declare @oldAmended bit
declare @oldConfirmed bit
declare @checkValue int

select @oldAmended=Amended,@oldConfirmed=Confirmed
  from adversefileopenlog
 where AdverseFileOpenLogID=@fileOpenLogId

if (@oldAmended!=@newAmended or @oldConfirmed!=@newConfirmed)
  begin
    set @checkValue=1
  end

if (@oldAmended=@newAmended and @oldConfirmed=@newConfirmed)
  begin 
   set @checkValue=0
  end

return @checkValue



