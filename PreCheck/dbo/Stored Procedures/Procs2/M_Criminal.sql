CREATE PROCEDURE M_Criminal AS
select c.apno, c.clear, c.county, c.ordered,a.userid,
    a.apdate, a.last, a.first, a.middle
,convert(numeric(7,2),dbo.elapsedbusinessdays(c.ordered,getdate())) as Elapsed
from crim c join appl a on c.apno = a.apno
where c.clear = 'O' and 
(A.ApStatus IN ('P','W')) 
and 
(SELECT COUNT(*) FROM Crim
	WHERE (Crim.Apno = A.Apno)
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = 'O'))) > 0
group by c.county,c.ordered,c.apno,a.last,a.middle,a.first,c.clear,a.userid,a.apdate
order by c.ordered,c.county
