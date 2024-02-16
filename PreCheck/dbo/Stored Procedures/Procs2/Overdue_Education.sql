
CREATE PROCEDURE [dbo].[Overdue_Education]  AS
-- Coded for online reporting  JS
SET NOCOUNT ON
/*SELECT     TOP 100 PERCENT A.APNO, A.ApStatus, A.UserID, E.Investigator, E.School, A.ApDate, A.ReopenDate, A.[Last], A.[First], A.Middle, 1 AS Educat_Count, 
                      CONVERT(numeric(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())) AS Elapsed, C.Name AS Client_Name, 
                      dbo.Users.Disabled
FROM         dbo.Appl A INNER JOIN
                      dbo.Client C ON A.CLNO = C.CLNO INNER JOIN
                      dbo.Educat E ON A.APNO = E.APNO INNER JOIN
                      dbo.Users ON A.Investigator = dbo.Users.UserID
WHERE     (A.ApStatus IN ('P', 'W')) AND (E.SectStat = 0 OR
                      E.SectStat = 9) AND
                          ((SELECT     COUNT(*)
                              FROM         Educat
                              WHERE     (Educat.Apno = A.Apno) AND (Educat.SectStat = 0 OR
                                                    Educat.SectStat = 9)) > 0)
ORDER BY elapsed DESC
-- A.ApDate
GO*/



SELECT     TOP 100 PERCENT A.APNO, A.ApStatus, E.Investigator, E.School, A.ApDate, A.ReopenDate, A.[Last], A.[First], A.Middle, 1 AS Educat_Count, 
                      CONVERT(numeric(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())) AS Elapsed, C.Name AS Client_Name, 
                      dbo.Users.Disabled
FROM         dbo.Appl A with (nolock) INNER JOIN
                      dbo.Client C  with (nolock) ON A.CLNO = C.CLNO INNER JOIN
                      dbo.Educat E  with (nolock) ON A.APNO = E.APNO LEFT OUTER JOIN
                      dbo.Users  with (nolock) ON A.Investigator = dbo.Users.UserID
WHERE     (A.ApStatus IN ('P', 'W')) AND (E.SectStat = '0' OR
                      E.SectStat = '9') AND E.IsOnReport = 1 AND
                          ((SELECT     COUNT(*)
                              FROM         Educat with (nolock) 
                              WHERE     (Educat.Apno = A.Apno) AND (Educat.SectStat = '0' OR
                                                    Educat.SectStat = '9') AND Educat.IsOnReport = 1) > 0)
ORDER BY elapsed DESC


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

