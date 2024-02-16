
CREATE PROCEDURE [dbo].[FormAdverseFileOpen_UpdAAStatus] 
@userId char(10)
AS
declare @adverseActionId int
declare @cnt int

set @cnt=(select count(*)from adverseaction where statusid=8 and adverseactionid in (select distinct adverseactionid from adversefileopenlog))

if @cnt>0
  begin
    -- update AdverseAction table
    update AdverseAction 
       set statusid=9 
     where statusid=8 
       and adverseactionid in (select distinct adverseactionid from adversefileopenlog)
    
    -- insert AdverseActionHistory table
    insert AdverseACtionHistory (AdverseActionID,AdverseChangeTypeID,StatusID,UserID,Date)
    select AdverseActionId,1,9,@userId,getdate() 
      from AdverseActionHistory 
     where StatusID=8
       and AdverseActionHistoryID in 
		(select max(h.AdverseActionHistoryID) 
                   from AdverseAction a,AdverseActionHistory h
		  where a.AdverseActionID=h.AdverseActionID
		    and a.StatusID=9
       		    and a.AdverseActionID in (select distinct AdverseActionID from AdverseFileOpenLog)
       		    and h.AdverseChangeTypeID=1
		 group by h.AdverseActionID 
		)
    order by AdverseActionid 
  end


