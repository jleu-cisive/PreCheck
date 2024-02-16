


CREATE PROCEDURE [dbo].[ReportApplByClient] 
@Clno int,
@StartDate DateTime, 
@EndDate DateTime 

AS

-- JS 7/28/2005
-- Returns list of Application per client

SELECT Client.CLNO, Appl.ApStatus,Appl.ApDate, Appl.APNO, Appl.[Last], Appl.[First], Appl.Middle, Appl.SSN
FROM Appl INNER JOIN
Client ON Appl.CLNO = Client.CLNO
--WHERE (Client.CLNO = @Clno) AND (Appl.ApDate >= CONVERT(DATETIME, @StartDate, 102)) AND (Appl.ApDate <= CONVERT(DATETIME, 
WHERE (Client.CLNO = @Clno) AND (Appl.ApDate >= CONVERT(DATETIME, @StartDate, 102)) AND (Appl.ApDate < CONVERT(DATETIME, 
@EndDate, 102))
ORDER BY Appl.ApDate


