-- Alter Procedure Crim_status_Report
CREATE PROCEDURE dbo.Crim_status_Report AS
/*select c.apno, c.clear, c.county, c.ordered,a.userid,
    a.apdate, a.last, a.first, a.middle
,convert(numeric(7,2),dbo.elapsedbusinessdays(c.ordered,getdate())) as Elapsed
  --'Elapsed'  = 
    --  case CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate()))
      --   when 4 then 1
       --  when 5 then 2
      --  when 6 then 3
    --    when 7 then 4
     --   else
     --   5
        
  -- end
from crim c join appl a on c.apno = a.apno
where c.clear = 'O' and 
(A.ApStatus IN ('P','W')) 
-- and not CONVERT(numeric(7,2), dbo.ElapsedBusinessDays(a.ApDate, getdate())) < 4  
and 
 (SELECT COUNT(*) FROM Crim
	WHERE (Crim.Apno = A.Apno)
	  AND ((Crim.Clear IS NULL) OR (Crim.Clear = 'O'))) > 0
order by a.apdate ,c.county*/

SELECT      c.APNO, c.Clear, TblCounties.A_County + ', ' + TblCounties.State AS county, c.Ordered, a.UserID, a.ApDate, a.[Last], 
                      a.[First], a.Middle, CONVERT(numeric(7, 2), dbo.ElapsedBusinessDays(c.Ordered, GETDATE())) AS Elapsed
FROM         Crim c INNER JOIN
                      Appl a ON c.APNO = a.APNO INNER JOIN
                      dbo.TblCounties ON c.CNTY_NO = TblCounties.CNTY_NO
WHERE     (c.Clear = 'O') AND (a.ApStatus IN ('P', 'W'))  AND
                          ((SELECT     COUNT(*)
                              FROM         Crim
                              WHERE     (Crim.Apno = A.Apno) AND ((Crim.Clear IS NULL) OR
                                                    (Crim.Clear = 'O'))) > 0)
ORDER BY a.ApDate, c.County
