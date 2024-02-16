
CREATE PROCEDURE [dbo].[Overdue_DNC_Per_Csr] @csrt varchar(20) AS


-- Overdue status per CSR
-- Coded for online reporting  JS
SET NOCOUNT ON
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,
       A.ApDate, A.Last, A.First, A.Middle, a.reopendate,
          C.Name AS Client_Name,
       'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())),
        
        (SELECT COUNT(*) FROM Empl  with (nolock)
	WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1
	  AND ( empl.sectstat = '9' and empl.dnc = 1)) AS Empl_Count
      
FROM Appl A with (nolock)
JOIN Client C  with (nolock) ON A.Clno = C.Clno
WHERE (A.ApStatus IN ('P','W')) and (a.userid = @csrt)
and (not CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate, getdate())) < '0')

ORDER BY  elapsed Desc




set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF

