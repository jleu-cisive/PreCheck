------------------------------------------------------------------------------------------------
-- Created By - Radhika Dereddy on 05/15/2018
-- Requester - Milton Robins
-- EXEC [PersonalReference_Records_Overdue_Status_Report]
--This Stored Procedure is used in [PersonalReference_Overdue_Status_Report_Summary]
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[PersonalReference_Overdue_Status_Report_Amy]  AS

SET NOCOUNT ON

-- get all clients accounts 

IF OBJECT_ID('tempdb..#ClientsToRun') IS NOT NULL
    DROP TABLE #ClientsToRun
SELECT * INTO #ClientsToRun     --- drop table #ClientsToRun
FROM
(
		SELECT c.clno, c.Name, c.WebOrderParentCLNO, 'parent' AS relation,  c.clno AS GroupID, C.AffiliateID
		FROM client c with(nolock)
		WHERE --c.clno IN (12721,7519,12444,13126)
				c.clno NOT IN (2135,3468)
		UNION  
		SELECT c2.clno, c2.Name, c2.WebOrderParentCLNO, 'child' AS relation, c2.WebOrderParentCLNO AS GroupID, C.AffiliateID
		FROM client c with(nolock) 
		INNER JOIN client c2 with(nolock) ON c2.WebOrderParentCLNO = c.CLNO
		WHERE --c.clno IN (12721,7519,12444,13126)
		c.clno NOT IN (2135,3468)
)x

--SELECT * FROM #ClientsToRun c  WHERE c.AffiliateID	IN (147,159) 
--ORDER BY GroupID, c.clno
--SELECT * FROM #ClientsToRun c  WHERE c.AffiliateID	IN (4,5)
--ORDER BY GroupID, c.clno


SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,A.ApDate, A.Last, A.First, A.Middle, a.reopendate,C.Name AS Client_Name, RA.Affiliate,RA.AffiliateID,
'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())), 
(case when A.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,
  ( SELECT COUNT(1) FROM PersRef  with(nolock)
        WHERE (PersRef.Apno = A.Apno) AND (PersRef.SectStat = '9') AND (PersRef.IsOnReport = 1) -- unocommented isonreport rdereddy 02/26/2019
  ) as PersRefCount
  into #tempPersRef1
 FROM Appl A with(nolock)
INNER JOIN #ClientsToRun C with(nolock) ON A.Clno = C.Clno
inner join refAffiliate RA with(nolock) on RA.AffiliateID = C.AffiliateID
WHERE (A.ApStatus IN ('P','W')) and a.CLNO not in (2135,3468)
AND A.Investigator IS NOT NULL

IF OBJECT_ID('tempdb..#ClientsToRun') IS NOT NULL
    DROP TABLE #ClientsToRun

--SELECT * FROM #tempPersRef1

select distinct APNO  into #tempPersRef2 
from #tempPersRef1
where PersRefCount = 0 


select DISTINCT * into #tempPersRef3 from #tempPersRef1 where APNO not in (Select APNO from #tempPersRef2) ORDER BY  elapsed Desc


Select * from #tempPersRef3

UNION ALL

select null [Apno], '' [ApStatus], '' [UserID], '' [Investigator], null [ApDate], '' [Last], '' [First], '' [Middle], null [reopendate], 
'' [Client_Name], '' [Affiliate], 0 [AffiliateID], 0 [Elapsed],
'total' as 'InProgressReviewed',sum(PersRefCount)
from #tempPersRef3



drop table #tempPersRef1
drop table #tempPersRef2
drop table #tempPersRef3

set ANSI_NULLS OFF


set QUOTED_IDENTIFIER OFF
