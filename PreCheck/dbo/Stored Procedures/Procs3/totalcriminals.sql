CREATE  PROCEDURE totalcriminals @client int,@timestart datetime,
	@timeend datetime
AS
SELECT  count(a.apno) as total,c.clno,
       C.Name AS Client_Name,a.apno,
       (SELECT COUNT(*) FROM Crim
	WHERE (Crim.Apno = A.Apno)
        and (crim.clear = 't')
	  )
        AS cleared,
        (SELECT COUNT(*) FROM crim
	WHERE (crim.Apno = A.Apno)
	  AND (crim.clear = 'f')) AS recordfound,
       (SELECT COUNT(*) FROM crim
	WHERE (crim.Apno = A.Apno)
	  AND (crim.clear = 'P' )) AS possible,
       (SELECT COUNT(*) FROM crim
	WHERE (crim.Apno = A.Apno)
	  AND (crim.clear = 'o')) AS Ordered
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE    A.compdate BETWEEN CONVERT(DATETIME, @timestart, 102) AND CONVERT(DATETIME, 
                      @timeend, 102) and c.clno = @client
--WHERE (A.ApStatus IN ('P','W'))  
--and A.a--pdate >= DATEADD(day, -2, getdate())
group by c.name,a.apno,c.clno
ORDER BY  c.name Desc
