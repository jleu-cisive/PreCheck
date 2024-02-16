-- Alter Procedure Rpt_Top3CountiesPerClient




CREATE      PROCEDURE dbo.Rpt_Top3CountiesPerClient AS


DECLARE @cv_name varchar(50)
DECLARE @cv_clno int
--  ==============================

delete from rpt_crim

DECLARE client_cursor CURSOR FOR 
SELECT clno, [name]
FROM client
where billingstatusid = 1
ORDER BY name

OPEN client_cursor

FETCH NEXT FROM client_cursor 
INTO @cv_clno, @cv_name

print @cv_name
WHILE @@FETCH_STATUS = 0
BEGIN
--  ==============================

insert into rpt_crim (clientname, Clno, ApCount, cnty_no, cnty_name)
select  top 3 cl.[name] ,cl.clno, count(*) as apcount,  ct.cnty_no, ct.county
from 	appl ap, crim cr, client cl, dbo.TblCounties ct
where  ap.apno = cr.apno
	and cl.clno = ap.clno
	and cr.cnty_no = ct.cnty_no
	and ap.clno = @cv_clno
and apdate between  '1/1/2004' and '12/30/2004'
group by cl.[name],cl.clno,  ct.cnty_no, ct.county
order by  apcount desc

FETCH NEXT FROM client_cursor 
INTO @cv_clno, @cv_name
--  ==============================
END

CLOSE client_cursor
DEALLOCATE client_cursor

update rpt_crim
set rpt_crim.clcrimrate = ccr.rate
from clientCrimrate ccr
where rpt_crim.clno = ccr.clno
and  rpt_crim.cnty_no = ccr.cnty_no

-- ==========================

update rpt_crim
set rpt_crim.cntydefrate = ccr.crim_defaultrate
from dbo.TblCounties ccr
where rpt_crim.cnty_no = ccr.cnty_no

--=================================
