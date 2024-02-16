
CREATE PROCEDURE [dbo].[FormAdverseFileOpenFinalize_UpdIns]
@adverseActionId int, 
@userId char(10)
AS
declare @statusid int

if @adverseActionId<0
  begin 
    set @statusid=10
  end
if @adverseActionId>0
  begin
    set @statusid=13
  end

  -- update AdverseAction table
  update AdverseAction 
     set statusid=@statusid 
     where adverseactionid= abs(@adverseActionId)
    
  -- insert AdverseActionHistory table
  insert AdverseACtionHistory (AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Date)
  values (abs(@adverseActionId),1,@statusid,@userId,getdate())


