
CREATE PROCEDURE [dbo].[Overdue_DL] AS
-- Coded for online overdue driver licenses - JS
SET NOCOUNT ON

SELECT     TOP 100 PERCENT A.APNO, A.ApStatus, A.UserID, A.Investigator, A.ApDate, A.[Last], A.[First], A.Middle, A.DL_State, A.DL_Number, CONVERT(numeric(7, 2), 
                      dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())) AS Elapsed, C.Name AS Client_Name,
                          (SELECT     COUNT(*)
                            FROM          DL  with (nolock)
                            WHERE      (DL.Apno = A.Apno) AND (DL.SectStat = '9')) AS DL_Count, dbo.Users.Disabled
FROM         dbo.Appl A  with (nolock) INNER JOIN
                      dbo.Client C  with (nolock) ON A.CLNO = C.CLNO INNER JOIN
                      dbo.Users  with (nolock) ON A.Investigator = dbo.Users.UserID
WHERE     (A.ApStatus IN ('P', 'W')) AND
                          ((SELECT     COUNT(*)
                              FROM         DL  with (nolock)
                              WHERE     (DL.Apno = A.Apno) AND (DL.SectStat = '9')) > 0)
							  and C.CLNO NOt in (2135, 3468)
ORDER BY elapsed DESC
-- A.ApDate



set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF