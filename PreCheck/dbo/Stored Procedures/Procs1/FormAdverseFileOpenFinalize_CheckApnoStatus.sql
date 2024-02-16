
CREATE PROCEDURE [dbo].[FormAdverseFileOpenFinalize_CheckApnoStatus] 
@fileOpenLogId int
AS
declare @checkValue int
declare @adverseActionId int
declare @cnt1 int
declare @cnt2 int
declare @cnt int

set @adverseActionId=(select AdverseActionID from AdverseFileOpenLog where AdverseFileOpenLogID=@fileOpenLogId)
set @cnt1=(select count(*) from AdverseFileOpenLog where AdverseActionID=@adverseActionID and Dispute=1)
set @cnt2=(select count(*) from AdverseFileOpenLog where AdverseActionID=@adverseActionID and Complete=1)
set @cnt=(select count(*) from AdverseFileOpenLog where AdverseActionID=@adverseActionId and amended=1)

if @cnt1=@cnt2
  begin
    if @cnt=0
      set @checkValue=(select AdverseActionID from AdverseFileOpenLog where AdverseFileOpenLogID=@fileOpenLogId)
    else if @cnt>0
      set @checkValue=-(select AdverseActionID from AdverseFileOpenLog where AdverseFileOpenLogID=@fileOpenLogId)
  end

else 
  begin
    set @checkValue=0
  end

return @checkValue


