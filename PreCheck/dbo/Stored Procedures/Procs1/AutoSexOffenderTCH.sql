


CREATE PROCEDURE [dbo].[AutoSexOffenderTCH] AS

declare @id int
declare @apno int
declare @state varchar(2)
declare @crimid int
create table #a (apno int, state varchar(2),  id int identity)
	
 insert	#a (apno, state) 
    select apno, state from appl where inuse = 'TCHoff_S'AND APNO NOT IN 
    (SELECT APNO FROM  Crim WHERE CNTY_NO=2480 AND APNO IN (SELECT APNO FROM Appl WHERE InUse = 'TCHoff_S' ))
         select @id = 0
		while @id < (select max(id) from #a)
                begin
			select @id = @id + 1
                        select 	@apno = apno,
                                        @state = state
				from	#a
			where	#a.id = @id
                       exec  createcrimsexoffender @state, @apno, 2480, @crimid
               
                 end
		
drop table #a 


Update Appl
set inuse = NULL
where inuse = 'TCHoff_S'


