-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified By Radhika Dereddy 10/02/2017 to remove 3468 Bad Apps and 3668 Zee demo
-- Modified by Lalit on 29-march-2023 for monthly service fee
-- =============================================
CREATE PROCEDURE [dbo].[Billing_ListUnbilledClients]
	
	
AS
BEGIN
	SET NOCOUNT ON

update a
set a.billed=1,
a.packageid=2399
----select * 
from Appl a where a.First='Monthly' AND a.Last='Service Fee' AND a.SSN='000-00-0000' AND a.ApDate>'2023-01-01' and a.CLNO NOT in (3468, 3668, 2135)
and (a.Billed<>1 or ISNULL(a.packageid,0) <>2399)

SELECT A.CLNO,C.Name
FROM Appl A
JOIN Client C on A.CLNO = C.CLNO
WHERE A.Billed = 0 --and A.CLNO NOT IN (3468, 3668, 2135)
Group by A.CLNO,C.Name
ORDER BY C.Name
END



