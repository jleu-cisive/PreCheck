------------------------------------------------------------------------------------------------
-- Created By - Radhika Dereddy on 05/10/2018
-- Requester - Chloe Cooper
-- EXEC [Education_Records_Overdue_Status_Report]
--This Stored Procedure is used in [Education_Overdue_Status_Report_Summary]
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Education_Overdue_Status_Report]  AS


SET NOCOUNT ON

SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,A.ApDate, A.Last, A.First, A.Middle, a.reopendate,C.Name AS Client_Name, RA.Affiliate,RA.AffiliateID,
'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())), 
(case when A.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,
  ( SELECT COUNT(1) FROM Educat  with(nolock)
        WHERE (Educat.Apno = A.Apno) AND (Educat.SectStat = '9') AND (Educat.IsOnReport = 1)
  ) as EducatCount
  into #temp1Educat1
 FROM Appl A with(nolock)
INNER JOIN Client C  with(nolock) ON A.Clno = C.Clno
inner join refAffiliate RA with(nolock) on RA.AffiliateID = C.AffiliateID
WHERE (A.ApStatus IN ('P','W')) and a.CLNO not in (2135,3468)
AND A.Investigator IS NOT NULL



select APNO  into #temp1Educat2 
from #temp1Educat1
where EducatCount = 0 


select * into #temp1Educat3 from #temp1Educat1 where APNO not in (Select APNO from #temp1Educat2) ORDER BY  elapsed Desc


Select * from #temp1Educat3

UNION ALL

select null [Apno], '' [ApStatus], '' [UserID], '' [Investigator], null [ApDate], '' [Last], '' [First], '' [Middle], null [reopendate], '' [Client_Name], '' [Affiliate], 0 [AffiliateID], 0 [Elapsed],
'total' as 'InProgressReviewed',sum(EducatCount)
from #temp1Educat3



drop table #temp1Educat1
drop table #temp1Educat2
drop table #temp1Educat3

set ANSI_NULLS OFF


set QUOTED_IDENTIFIER OFF
