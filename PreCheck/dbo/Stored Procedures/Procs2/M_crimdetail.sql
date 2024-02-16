CREATE PROCEDURE M_crimdetail @thecounty varchar(100),@thedate varchar(20) AS
select c.apno, c.clear,c.crimid, c.county, c.ordered,a.userid,
    a.apdate, a.last, a.first, a.middle
,convert(numeric(7,2),dbo.elapsedbusinessdays(c.ordered,getdate())) as Elapsed
from crim c join appl a on c.apno = a.apno
where c.clear = 'O' and 
(A.ApStatus IN ('P','W')) 
and 
c.county = @thecounty and ordered = @thedate