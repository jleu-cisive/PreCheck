CREATE PROCEDURE XMLAppls2 
@UserID as varchar(8)
AS
SET NOCOUNT ON

if @UserID=''
SELECT A.Apno, A.ApStatus, A.NeedsReview,  A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, 
       C.Name AS Client_Name
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) and (A.EnteredVia IN ('XML','WEB') )
ORDER BY A.ApDate

else

SELECT A.Apno, A.ApStatus, A.NeedsReview,  A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, 
       C.Name AS Client_Name
FROM Appl A
JOIN Client C ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) and (A.EnteredVia IN ('XML','WEB') ) and A.UserID=@UserID
ORDER BY A.ApDate