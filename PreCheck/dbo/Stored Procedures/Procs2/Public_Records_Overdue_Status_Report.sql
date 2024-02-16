------------------------------------------------------------------------------------------------
-- Created By - Radhika Dereddy on 02/26/2018
-- Requester - Misty Smallwood
-- Change Request - Clone the Overdue_Status_report to show some stats only pertaining to Public records which are in progress and Investigator is not null
-- ***** History of  the original report is below *******
-- Modified By Radhika dereddy on 06/06/2017 to include 'InProgressReviewed' column as requested by BrianSilver
-- Modified By Radhika dereddy on 07/25/2017 to include criminal records that are in ( Vendor Reviewed status, Transferred Record, Needs Research,
-- Waiting,Error Getting Results,Error Sending Order,Ordering,Alias Name Ordered,Needs QA,Review Reportability,Reinvestigations) treated as open 
-- with the exception of Clear, Record Found, Possible or More Info Needed are the only closure statuses that would meet the criteria to exclude from the Overdue Status Report.
-- This Stored Procedure is used in [Public_Records_Overdue_Status_Report_Summary]
---------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Public_Records_Overdue_Status_Report]  AS


SET NOCOUNT ON

SELECT A.Apno, A.ApStatus, A.UserID, A.Investigator,A.ApDate, A.Last, A.First, A.Middle, a.reopendate,C.Name AS Client_Name, RA.Affiliate,RA.AffiliateID,
'Elapsed'  = CONVERT(numeric(7,2), dbo.NewElapsedBusinessDays(a.Reopendate,a.ApDate,getdate())), 
(case when A.InProgressReviewed = 0 then 'False' else 'True' end) as InProgressReviewed,
( SELECT COUNT(1) FROM Crim with (nolock) WHERE (Crim.Apno = A.Apno And IsHidden=0) 
	AND 
	  (
	  --OR (Crim.Clear = 'I')
		(Crim.Clear = 'O') OR (Crim.Clear = 'R')  OR (Crim.Clear = 'Z') OR (Crim.Clear = 'W')
		OR (Crim.Clear = 'X') OR (Crim.Clear = 'E') OR (Crim.Clear = 'M') OR (Crim.Clear = 'V') OR (Crim.Clear = 'N') OR (Crim.Clear = 'Q') 
		OR (Crim.Clear = 'D') 
		OR (Crim.Clear = 'G')
	  )
) AS Crim_Count
 into #temp1
FROM Appl A with (nolock)
JOIN Client C  with (nolock) ON A.Clno = C.Clno
inner join refAffiliate RA on RA.AffiliateID = C.AffiliateID
WHERE (A.ApStatus IN ('P','W')) and a.CLNO not in (2135,3468)
AND A.Investigator IS NOT NULL



select APNO  into #temp2 
from #temp1
where Crim_Count = 0 


select * into #temp3 from #temp1 where APNO not in (Select APNO from #temp2) ORDER BY  elapsed Desc


Select * from #temp3

UNION ALL

select null [Apno], '' [ApStatus], '' [UserID], '' [Investigator], null [ApDate], '' [Last], '' [First], '' [Middle], null [reopendate], '' [Client_Name], '' [Affiliate], 0 [AffiliateID], 0 [Elapsed],
'total' as 'InProgressReviewed',sum(Crim_count)
from #temp3



drop table #temp1
drop table #temp2
drop table #temp3

set ANSI_NULLS OFF


set QUOTED_IDENTIFIER OFF
