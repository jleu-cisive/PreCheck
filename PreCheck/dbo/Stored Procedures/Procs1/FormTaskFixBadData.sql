CREATE  PROCEDURE [dbo].[FormTaskFixBadData] AS

--fix the duplicated view orders
DECLARE @dupVO int, @nVO int, @Count int

DECLARE TaskDupVieworder_Cursor CURSOR FOR
select vieworder from task group by vieworder having count(1)>1


OPEN TaskDupVieworder_Cursor
FETCH TaskDupVieworder_Cursor INTO @dupVO 
WHILE @@Fetch_Status = 0
BEGIN--begin cursor

     set @Count=1
     if(@dupVO is not null)
     begin --begin if
	--print @dupVO
	--DECLARE @dupVO int, @nVO int, @Count int
        while(select count(1) from task  where vieworder=@dupVO+@Count)!=1
        begin
	    set @Count=@Count+1
	    CONTINUE
        end
	set @nVO=(select vieworder from task where (vieworder=@dupVO+@Count) )
	
	--print @nVO
	while(@nVO is null)
	 begin
		set @Count=@Count+1
		--print @missCount
		set @nVO=(select vieworder from task where vieworder=(@dupVO+@Count))
		print @nVO
		CONTINUE
	 end

	update task set ViewOrder=(viewOrder+@Count) where vieworder>(@dupVO)

	update task set ViewOrder=(viewOrder+1) 
	where (vieworder=@dupVO 
		and taskid=(select max(taskid) from task where vieworder=@dupVO))

     end
     FETCH TaskDupVieworder_Cursor INTO @dupVO
END
CLOSE TaskDupVieworder_Cursor
DEALLOCATE TaskDupVieworder_Cursor

--======================================================
DECLARE @missVO int, @nextVO int, @missCount int

set @missVO=(select min(ViewOrder + 1)
from task
where ViewOrder + 1 not in (select ViewOrder from task))

--print @missVO
--fix the missing view orders
set @missCount=1
if(@missVO is not null and @missVO<(select count(*) from task))
   begin
	set @nextVO=(select vieworder from task where vieworder=(@missVO+@missCount))
	--print @nextVO
	while(@nextVO is null)
	  begin
		set @missCount=@missCount+1
		--print @missCount
		set @nextVO=(select vieworder from task where vieworder=(@missVO+@missCount))
		CONTINUE
	  end
	update task set ViewOrder=(viewOrder-@missCount) where vieworder>(@missVO-1)
   end