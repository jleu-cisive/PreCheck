/*
Modified By: Sunil Mandal
Modified Date: 16-Aug-2022
Description: Ticket #57889 Add column request - Overdue Status Report
EXEC [dbo].[Overdue_status_report]

*/

CREATE PROCEDURE  [dbo].[Overdue_status_report]  
AS  
  
-- Coded for online reporting  JS  
SET NOCOUNT ON  
  
SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,A.ApDate, A.Last, A.First, A.Middle, a.reopendate,
a.OrigCompDate As OriginalCloseDate -- Modified By: Sunil Mandal, Ticket #57889 Added New column OriginalCloseDate
,C.Name AS Client_Name, C.CLNO, RA.Affiliate,  
'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())),   
(case when A.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,  
( SELECT COUNT(1) FROM Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0)   
 AND   
   (  
  (Crim.Clear IS NULL) OR (Crim.Clear = 'O') OR (Crim.Clear = 'R') OR (Crim.Clear = 'V') OR (Crim.Clear = 'Z') OR (Crim.Clear = 'W')  
   OR (Crim.Clear = 'X') OR (Crim.Clear = 'E') OR (Crim.Clear = 'M') OR (Crim.Clear = 'N') OR (Crim.Clear = 'Q') OR (Crim.Clear = 'D') OR (Crim.Clear = 'G')  
   )  
) AS Crim_Count,  
(SELECT 0) AS Civil_Count,  
(SELECT COUNT(1) FROM Credit with (nolock) WHERE (Credit.Apno = A.Apno And IsHidden=0) AND (Credit.SectStat = '9' or credit.sectstat='0') ) AS Credit_Count,  
(SELECT COUNT(1) FROM DL with (nolock) WHERE (DL.Apno = A.Apno And IsHidden=0) AND (DL.SectStat = '9' or DL.SectStat = '0')) AS DL_Count,  
(SELECT COUNT(1) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND Empl.IsOnReport = 1  AND (Empl.SectStat = '9' or empl.sectstat = '0')) AS Empl_Count,  
(SELECT COUNT(1) FROM Educat with (nolock) WHERE (Educat.Apno = A.Apno) AND Educat.IsOnReport = 1 AND (Educat.SectStat = '9' or Educat.SectStat = '0')) AS Educat_Count,  
(SELECT COUNT(1) FROM ProfLic with (nolock) WHERE (ProfLic.Apno = A.Apno) AND ProfLic.IsOnReport = 1 AND (ProfLic.SectStat = '9' or ProfLic.SectStat = '0')) AS ProfLic_Count,  
(SELECT COUNT(1) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND PersRef.IsOnReport = 1 AND (PersRef.SectStat = '9' or PersRef.SectStat = '0')) AS PersRef_Count,  
(SELECT COUNT(1) FROM medinteg with (nolock) WHERE (medinteg.Apno = A.Apno and IsHidden = 0) AND (medinteg.SectStat = '9' or medinteg.SectStat = '0')) AS Medinteg_Count  
 -- into #temp1											Code commented on the behalf of HDT #54462
FROM Appl A with (nolock)  
JOIN Client C  with (nolock) ON A.Clno = C.Clno  
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID  
WHERE (A.ApStatus IN ('P','W',''))						-- Added '' on the behalf of HDT #54462
and     
a.CLNO not in (2135,3468)  
ORDER BY  elapsed Desc 

--and not CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())) <= 0 and A.apdate >= DATEADD(day, -2, getdate())  
-- A.ApDate  

/*			Code commented on the behalf of HDT #54462
select APNO -- into #temp2   
from #temp1  
where Crim_Count = 0   
and Civil_Count = 0   
and Credit_Count = 0   
and DL_Count = 0   
and Empl_Count = 0   
and Educat_Count = 0   
and ProfLic_Count = 0   
and PersRef_Count = 0   
and Medinteg_Count = 0  
  
  
select  * from #temp1 where APNO not in (Select APNO from #temp2) ORDER BY  elapsed Desc  
*/
  
  
--drop table #temp1  
--drop table #temp2  
  
  
set ANSI_NULLS OFF  
  
  
set QUOTED_IDENTIFIER OFF  
