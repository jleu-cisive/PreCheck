CREATE PROCEDURE [tobedeleted].[TestFromRay] AS
SET NOCOUNT ON
SELECT TOP 10 A.Apno, A.ApStatus, A.NeedsReview,  A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, 
       C.Name AS Client_Name
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) and (A.EnteredVia IN ('XML','WEB') )
ORDER BY A.ApDate