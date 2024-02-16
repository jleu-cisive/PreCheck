-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[AppLockInUseEscalation]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
    CREATE TABLE #locktemp   (apno INT,userid varchar(50)  )  
    insert  into #locktemp (apno,userid)
    select apno,inuse from appl where inuse is not null
    
   --delete on no match
   delete from applockescalation where apno not in (select a.apno from applockescalation a inner join #locktemp c on a.apno = c.apno 
   and a.userid = c.userid)
   --update on match
     update applockescalation set locklevel = locklevel + 1 where apno in (select a.apno from applockescalation a inner join #locktemp c on a.apno = c.apno 
   and a.userid = c.userid)
   --insert on absence
   insert into applockescalation (apno,userid)
   select apno, userid from #locktemp c where (select count(*) from applockescalation where apno = c.apno and userid = c.userid) = 0 
   
    DROP TABLE #locktemp;      
    
    --auto clear inuse >= 3 hours
    update appl set inuse = null from appl  a inner join applockescalation  b
 on a.apno = b.apno and a.inuse = b.userid
where b.locklevel >= 10
--remove from table
delete from applockescalation where locklevel >= 10

--added by schapyala on 5/5/13
--Section level inuse clear if more than an  halfhhour
update dbo.empl
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30

update dbo.Educat
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30

update dbo.persref
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30

update dbo.proflic
Set InUse = null,inuse_timestamp=null
Where Datediff(minute,inuse_timestamp,current_timestamp) >= 30


    --pull from table
    select * from applockescalation order by userid asc
   
END
