
CREATE PROCEDURE ReportSalesApplsByClient @Clno int,@StartDate DateTime, @EndDate DateTime AS

-- JS 7/28/2005
-- Returns list of Application per client

SELECT TOP 100 PERCENT Client.CLNO, Appl.ApDate, Appl.APNO, Appl.[Last], Appl.[First], Appl.Middle, Appl.SSN
FROM Appl INNER JOIN
Client ON Appl.CLNO = Client.CLNO
WHERE (Client.CLNO = @Clno) AND (Appl.ApDate >= CONVERT(DATETIME, @StartDate, 102)) AND (Appl.ApDate <= CONVERT(DATETIME, 
@EndDate, 102))
ORDER BY Appl.ApDate

