﻿CREATE PROCEDURE ListUnbilledClients
AS
SET NOCOUNT ON
SELECT DISTINCT A.CLNO, C.Name
FROM Appl A
JOIN Client C on A.CLNO = C.CLNO
WHERE A.Billed = 0
ORDER BY C.Name
