

CREATE PROCEDURE [dbo].[Overdue_license]  AS
-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT      A.APNO, A.ApStatus, A.UserID, p.Investigator, A.ReopenDate, A.ApDate, A.[Last], A.[First], A.Middle, p.Lic_Type, p.State, 
                      CONVERT(numeric(7, 2), dbo.NewElapsedBusinessDays(A.ReopenDate, A.ApDate, GETDATE())) AS Elapsed, C.Name AS Client_Name,
                          (SELECT     COUNT(*)
                            FROM          ProfLic with (nolock)
                            WHERE      (ProfLic.Apno = A.Apno) AND (ProfLic.SectStat = '9') AND ProfLic.IsOnReport = 1 AND ProfLic.IsHidden = 0) AS ProfLic_Count, dbo.Users.Disabled
FROM         dbo.Appl A  with (nolock) INNER JOIN
                      dbo.Client C  with (nolock) ON A.CLNO = C.CLNO INNER JOIN
                      dbo.ProfLic p  with (nolock) ON A.APNO = p.Apno INNER JOIN
                      dbo.Users  with (nolock) ON A.Investigator = dbo.Users.UserID
WHERE     (A.ApStatus IN ('P', 'W'))  AND
                          ((SELECT     COUNT(*)
                              FROM         ProfLic with (nolock)
                              WHERE     (ProfLic.Apno = A.Apno) AND (ProfLic.SectStat = '9') AND ProfLic.IsOnReport = 1 AND ProfLic.IsHidden = 0) > 0) AND (p.SectStat = '9')
ORDER BY elapsed DESC


set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF


